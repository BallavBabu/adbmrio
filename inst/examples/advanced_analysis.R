# =============================================================================
#  ADBMRIO: ADVANCED RESEARCH COOKBOOK
#  ---------------------------------------------------------------------------
#  This script provides 7 standard economic research scenarios using the 
#  adbmrio package. Each section acts as a standalone template.
#
#  SCENARIOS:
#  1. One-to-Many: China's exports to the World
#  2. Sector-Specific: The Global Electronics Supply Chain
#  3. National Level: GVC Participation Rates (The "Who is integrated?" test)
#  4. Deep Dive: The VAX Ratio (Johnson & Noguera Style)
#  5. Structural: Upstream vs. Downstream Positioning
#  6. Regional: "Factory Asia" Integration (Intra-regional trade)
#  7. Time Series: Tracking changes over years
# =============================================================================

# --- 0. GLOBAL SETUP ---------------------------------------------------------
library(adbmrio)
library(data.table)

# LOAD DATA ONCE
# REPLACE with your actual path
mrio <- load_adb_mrio("~/LB_files/4rh Paper/Data/ADB_MRIO_Panel_2017_2023_with_CO2.rds")
# -----------------------------------------------------------------------------


# =============================================================================
# 1. ONE-TO-MANY ANALYSIS
# Goal: Identify China's (PRC) largest GVC partners in 2020
# =============================================================================

# A. Run the full workflow (Calculates all 63 x 62 pairs)
# This is more efficient than running a loop for just one country
full_2020 <- calculate_full_year_gvc(mrio, year = 2020)

# B. Filter: Extract rows where Exporter is China (Index 8)
china_exports <- full_2020$bilateral[s_index == 8]

# C. Aggregate by Partner Country
top_partners <- china_exports[, .(
  Gross_Exports = sum(EX_direct),
  GVC_Trade = sum(Tg),       # Complex GVC crossing borders
  Traditional_Trade = sum(Ti) # Direct intermediate usage
), by = .(r_country)]

# D. Sort and View
print(head(top_partners[order(-GVC_Trade)], 10))


# =============================================================================
# 2. SECTOR-SPECIFIC ANALYSIS
# Goal: Analyze the "Electrical and Optical Equipment" sector (Electronics)
# =============================================================================

# A. Filter the full dataset for the Electronics sector
# Note: We use 'like' to match text, or use sector_ix if you know the number
electronics_gvc <- full_2020$bilateral[sector %like% "Electrical"]

# B. Research Question: Which country exports the most Embodied CO2 
#    specifically in the Electronics sector?
co2_leaders <- electronics_gvc[, .(
  Total_Embodied_CO2 = sum(EEX_direct),
  Total_Value_Added  = sum(VAX_direct)
), by = s_country]

# C. View Top 5 Polluters in Electronics
print(head(co2_leaders[order(-Total_Embodied_CO2)], 5))


# =============================================================================
# 3. NATIONAL GVC PARTICIPATION
# Goal: Compare GVC Integration of major economies
# Formula: Participation = (GVC Exports / Total Gross Exports)
# =============================================================================

# A. Use the national_totals table (already aggregated by the package)
national_data <- full_2020$national_totals

# B. Calculate the Ratio
national_data[, GVC_Ratio := X_Tg / X_direct]

# C. Compare specific countries
targets <- c("PRC", "IND", "USA", "GER", "JPN", "VNM", "THA")
comparison <- national_data[s_country %in% targets, .(
  Country = s_country,
  Total_Output_Millions = round(X_direct, 0),
  GVC_Related_Output = round(X_Tg, 0),
  GVC_Participation_Rate = round(GVC_Ratio, 3)
)]

# D. Sort by Participation Rate (Who is most integrated?)
print(comparison[order(-GVC_Participation_Rate)])


# =============================================================================
# 4. THE VAX RATIO (Johnson & Noguera Style)
# Goal: Calculate the ratio of Value-Added to Gross Exports.
# A low VAX ratio indicates high use of foreign inputs (high GVC integration).
# =============================================================================

# A. Calculate VAX Ratio for every country-sector pair
# We use the bilateral table but aggregate to the sector level first
sector_vax <- full_2020$bilateral[, .(
  Gross_Exp = sum(EX_direct),
  Value_Added_Exp = sum(VAX_direct)
), by = .(s_country, sector)]

# B. Compute Ratio
sector_vax[, VAX_Ratio := Value_Added_Exp / Gross_Exp]

# C. Example: Check India's (Index 22) VAX Ratios by Sector
india_vax <- sector_vax[s_country == "IND"]
print(india_vax[order(VAX_Ratio)]) 
# Note: Manufacturing usually has lower VAX ratios than Services.


# =============================================================================
# 5. STRUCTURAL POSITION (Upstream vs. Downstream)
# Goal: Is a country selling Intermediates (Upstream) or Final Goods (Downstream)?
# =============================================================================

# A. Aggregate totals
position_data <- full_2020$national_totals[, .(
  s_country,
  Exports_Final = X_Tf,         # Sold as final goods (Downstream)
  Exports_Intermediate = X_Ti,  # Sold as inputs (Upstream)
  Exports_GVC = X_Tg            # Sold into complex chains (Deep GVC)
)]

# B. Calculate "Upstreamness Proxy"
position_data[, Upstream_Share := (Exports_Intermediate + Exports_GVC) / 
                (Exports_Final + Exports_Intermediate + Exports_GVC)]

# C. View
print(head(position_data[order(-Upstream_Share)], 10))
# Mining/Resource countries should appear at the top.


# =============================================================================
# 6. REGIONAL VALUE CHAINS (RVC) - "Factory Asia"
# Goal: How much of "Factory Asia" trade stays within Asia?
# =============================================================================

# A. Define the region (Indices or Codes)
# PRC, JPN, KOR, IND, and ASEAN nations (Example subset)
asia_codes <- c("PRC", "JPN", "KOR", "IND", "INO", "MAL", "PHI", "THA", "VNM")

# B. Filter bilateral flows where BOTH Source and Destination are in Asia
intra_asia <- full_2020$bilateral[s_country %in% asia_codes & r_country %in% asia_codes]

# C. Filter flows where Source is Asia but Destination is Rest of World
asia_to_world <- full_2020$bilateral[s_country %in% asia_codes & !r_country %in% asia_codes]

# D. Compare Totals
intra_val <- sum(intra_asia$EX_direct)
extra_val <- sum(asia_to_world$EX_direct)

cat(paste0("Intra-Asian Trade: $", round(intra_val/1e6, 2), " Trillion\n"))
cat(paste0("Asia-to-World Trade: $", round(extra_val/1e6, 2), " Trillion\n"))
cat(paste0("Regional Integration Index: ", round(intra_val / (intra_val+extra_val), 3), "\n"))


# =============================================================================
# 7. TIME SERIES ANALYSIS
# Goal: Track how India's GVC exports (Tg) changed from 2017 to 2023
# =============================================================================

# A. Define years
years_to_scan <- c(2017, 2018, 2019, 2020, 2021, 2022, 2023)
history_list <- list()

# B. Loop
for (yr in years_to_scan) {
  message(paste("Processing Year:", yr))
  
  # Run full analysis (This takes time per year!)
  res <- calculate_full_year_gvc(mrio, yr)
  
  # Extract India (Index 22) national totals
  ind_data <- res$national_totals[s_index == 22]
  ind_data[, year := yr] # Tag with year
  
  history_list[[as.character(yr)]] <- ind_data
}

# C. Bind and Analyze
india_ts <- rbindlist(history_list)

# Compare Growth of GVC trade vs Gross Trade
print(india_ts[, .(year, Gross_Output=X_direct, GVC_Output=X_Tg)])