# =============================================================================
# Generate HTML pages for observed + SSP585 scenarios
# + Generate static map images for the landing page
# =============================================================================

library(raster)
library(terra)
library(cmocean)
library(ggplot2)
library(ggthemes)

# =============================================================================
# SECTION 1: Render map HTML pages
# =============================================================================

scenario_vec <- c("observed", "ssp585")
type_vec <- c("absolute", "relative")

output_dir <- normalizePath("..")  # website root

for (scenario in scenario_vec) {
  for (type in type_vec) {
    CURRENT_SCENARIO <- scenario
    CURRENT_TYPE <- type
    filename <- paste0(CURRENT_SCENARIO, "_", CURRENT_TYPE, ".html")
    
    cat("Rendering:", filename, "\n")
    rmarkdown::render(
      "map_template_comparable.Rmd", 
      output_file = filename,
      output_dir = output_dir
    )
  }
}

cat("\nGenerated HTML files in", output_dir, ":\n")
cat("  - observed_absolute.html\n")
cat("  - observed_relative.html\n")
cat("  - ssp585_absolute.html\n")
cat("  - ssp585_relative.html\n")

# =============================================================================
# SECTION 2: Generate static map images (PNG) for landing page
# =============================================================================
# Reads the binned tif files (EPSG:3857), reprojects back to EPSG:4326,
# converts to a data frame with x/y/bin, and plots with ggplot2 + geom_tile
# using the exact same approach as plot_maps_comparable_newbase.R / 
# functions_maps_comparable.R:
#   - geom_tile() with coord_equal()
#   - xlim(-180, 180), ylim(-70, 90)
#   - cmocean 'curl' palette (direction = -1, clip = 0.1)
#   - theme_map() from ggthemes
#   - ggsave at 4320 x 2160 px
#
# Generates:
#   - map_absolute_4160.png  (absolute change, 2041-2060 SSP585)
#   - map_percentage_4160.png (percentage change, 2041-2060 SSP585)
# =============================================================================

cat("\n--- Generating static map images ---\n")

# Color palette: same as in functions_maps_comparable.R bin_plot_comparable()
# 11 bins: -5, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5
all_bins <- c(-5, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5)
my_color <- cmocean(name = 'curl', direction = -1, clip = 0.1)(11)
names(my_color) <- as.character(all_bins)

# Override bin 0: slightly darker than the default cream midpoint.
# A very light warm grey that is subtly visible against the white background
# but won't compete with the dark overlay on the hero section.
# The bin -1 color (lightest negative) is a warm salmon — this stays distinct.
my_color["0"] <- "#E8E6E0"

generate_map_image <- function(tif_file, output_file) {
  
  cat("Reading:", tif_file, "\n")
  
  # Read the EPSG:3857 tif and reproject to EPSG:4326
  r_3857 <- terra::rast(tif_file)
  r_4326 <- terra::project(r_3857, "EPSG:4326", method = "near")
  
  # Convert to data frame (x, y, bin)
  df <- as.data.frame(r_4326, xy = TRUE, na.rm = TRUE)
  colnames(df) <- c("x", "y", "bin")
  df$bin <- round(df$bin)
  
  cat("  Cells:", nrow(df), "\n")
  cat("  Bin distribution:\n")
  print(table(df$bin))
  
  # Map colors exactly as in the original code:
  # color_map uses only bins present in data, same as bin_plot_comparable
  # but we define all 11 for consistency
  color_map <- my_color[as.character(all_bins)]
  
  # Plot: same structure as bin_plot_comparable but cropped tighter
  p <- ggplot(df, aes(x, y)) +
    geom_tile(aes(fill = as.character(bin))) +
    coord_equal(xlim = c(-125, 150), ylim = c(-55, 75)) +
    scale_fill_manual(
      values = color_map,
      breaks = as.character(all_bins),
      drop = FALSE
    ) +
    theme_map() +
    theme(
      legend.position = "none",
      plot.title = element_blank(),
      plot.subtitle = element_blank()
    )
  
  # Save: same dimensions as the original maps
  output_path <- file.path(output_dir, output_file)
  ggsave(output_path, p,
         device = "png", type = "cairo",
         width = 4320, height = 2160, units = "px",
         bg = "white", limitsize = FALSE)
  
  cat("Saved:", output_path, "\n")
  return(invisible(output_path))
}

# Generate absolute change map (2041-2060, SSP585)
generate_map_image(
  tif_file = "bin_change_ssp585_comp_4160.tif",
  output_file = "map_absolute_4160.png"
)

# Generate percentage change map (2041-2060, SSP585)
generate_map_image(
  tif_file = "cal_growth_rate_ssp585_comparable_4160.tif",
  output_file = "map_percentage_4160.png"
)

cat("\n--- Map images generated ---\n")
cat("To use as hero background: update index.html background-image url\n")
cat("  e.g. url('map_absolute_4160.png') or url('map_percentage_4160.png')\n")
