# =============================================================================
# Leaflet maps for comparable binned climate-agriculture data
# With separate legend rendering and proper color mapping
# =============================================================================

library(raster)
library(cmocean)
library(leaflet)
library(htmltools)

tif_path <- "."

# =============================================================================
# DEFINE BIN VALUES, LABELS, AND THRESHOLDS
# =============================================================================

# All possible bin values: -5 to 5 (11 total)
all_bins <- c(-5, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5)

# Colors for 11 bins - explicitly ordered from most negative to most positive
# Color 6 (middle) will be the white/cream for zero
bin_colors <- cmocean(name = 'curl', direction = -1, clip = 0.1)(11)
names(bin_colors) <- as.character(all_bins)

# PFY thresholds for legend display
pfy_thresholds <- c(
  "< -80,000",
  "-80,000 to -50,000",
  "-50,000 to -10,000",
  "-10,000 to -1,000",
  "-1,000 to 0",
  "0 (No change)",
  "0 to 1,000",
  "1,000 to 10,000",
  "10,000 to 50,000",
  "50,000 to 80,000",
  "> 80,000"
)

# Growth rate thresholds for legend display
growth_thresholds <- c(
  "< -75%",
  "-75% to -50%",
  "-50% to -25%",
  "-25% to -10%",
  "-10% to 0%",
  "0% (No change)",
  "0% to 25%",
  "25% to 50%",
  "50% to 100%",
  "100% to 500%",
  "> 500%"
)

# =============================================================================
# LEAFLET FUNCTION - NO LEGEND, FIXED COLOR MAPPING
# =============================================================================

leaflet_function_comparable <- function(file_name, title, variable_type = "pfy") {
  
  x <- raster(file_name)
  
  # Create color palette with EXPLICIT domain covering all possible values
  # This ensures bin 0 always gets the middle (white) color
  pal <- colorFactor(
    palette = bin_colors,
    domain = all_bins,
    levels = all_bins,
    ordered = TRUE,
    na.color = "transparent"
  )
  
  # Create map WITHOUT legend
  out_plot <- leaflet() %>%
    addRasterImage(
      x = x,
      colors = pal,
      opacity = 1,
      project = FALSE
    ) %>%
    setView(lng = 0, lat = 10, zoom = 1.5)
  
  return(out_plot)
}

# =============================================================================
# STANDALONE LEGEND AS HTML - VERTICAL WITH THRESHOLD VALUES
# =============================================================================

create_legend_html <- function(variable_type = "pfy", title = "Legend") {
  
  if (variable_type == "growth") {
    thresholds <- growth_thresholds
  } else {
    thresholds <- pfy_thresholds
  }
  
  # Build legend items
  legend_items <- lapply(1:11, function(i) {
    tags$div(
      style = "display: flex; align-items: center; margin: 4px 0;",
      tags$span(
        style = paste0(
          "display: inline-block; width: 24px; height: 16px; ",
          "background-color: ", bin_colors[i], "; ",
          "margin-right: 10px; border: 1px solid #999; border-radius: 2px;"
        )
      ),
      tags$span(thresholds[i], style = "font-size: 13px; color: #333;")
    )
  })
  
  legend_div <- tags$div(
    style = paste0(
      "background: white; ",
      "padding: 15px 20px; ",
      "border-radius: 8px; ",
      "box-shadow: 0 2px 6px rgba(0,0,0,0.15); ",
      "display: inline-block; ",
      "font-family: Arial, sans-serif;"
    ),
    tags$div(
      style = "font-weight: bold; margin-bottom: 12px; font-size: 14px; color: #2c3e50;",
      title
    ),
    tagList(legend_items)
  )
  
  return(legend_div)
}

# =============================================================================
# STANDALONE LEGEND - HORIZONTAL WITH THRESHOLD VALUES
# =============================================================================

create_legend_html_horizontal <- function(variable_type = "pfy", title = "Legend") {
  
  if (variable_type == "growth") {
    thresholds <- growth_thresholds
    short_labels <- c("<-75%", "-75%", "-50%", "-25%", "-10%", "0%", "25%", "50%", "100%", "500%", ">500%")
  } else {
    thresholds <- pfy_thresholds
    short_labels <- c("<-80k", "-80k", "-50k", "-10k", "-1k", "0", "1k", "10k", "50k", "80k", ">80k")
  }
  
  # Color bar
  color_boxes <- lapply(1:11, function(i) {
    tags$div(
      style = paste0(
        "flex: 1; height: 24px; ",
        "background-color: ", bin_colors[i], ";"
      ),
      title = thresholds[i]  # tooltip on hover
    )
  })
  
  # Labels
  label_items <- lapply(1:11, function(i) {
    tags$div(
      style = "flex: 1; text-align: center; font-size: 10px; color: #555;",
      short_labels[i]
    )
  })
  
  legend_div <- tags$div(
    style = paste0(
      "background: white; ",
      "padding: 15px 20px; ",
      "border-radius: 8px; ",
      "box-shadow: 0 2px 6px rgba(0,0,0,0.15); ",
      "font-family: Arial, sans-serif; ",
      "max-width: 700px; ",
      "margin: 20px auto;"
    ),
    tags$div(
      style = "font-weight: bold; margin-bottom: 10px; font-size: 14px; text-align: center; color: #2c3e50;",
      title
    ),
    tags$div(
      style = "display: flex; border: 1px solid #999; border-radius: 3px; overflow: hidden;",
      tagList(color_boxes)
    ),
    tags$div(
      style = "display: flex; margin-top: 6px;",
      tagList(label_items)
    )
  )
  
  return(legend_div)
}

# =============================================================================
# ORIGINAL FUNCTION (backwards compatibility - still has legend)
# =============================================================================

leaflet_function <- function(file_name, title){
  x <- raster(file_name)
  if(grepl("growth", file_name)){
    values(x) <- round(values(x), 3)
  }
  pal = colorFactor(cmocean(name = 'curl', direction = -1, clip = 0.1)(11), sort(unique(values(x))),
                    ordered = TRUE, 
                    na.color = "transparent")
  out_plot <- leaflet() %>% 
    addRasterImage(x = x , 
                   colors = pal, 
                   opacity = 1,
                   project = FALSE) %>%
    addLegend(pal = pal, values = values(x),
              title = title, position = "bottomleft") %>%
    setView(lng = 0, lat = 10, zoom = 1.5)
  
  return(out_plot)
}

# =============================================================================
# FILE LISTS
# =============================================================================

absolute_tifs <- list.files(path = tif_path, pattern = "bin_change", full.names = TRUE)
relative_tifs <- list.files(path = tif_path, pattern = "cal_growth_rate", full.names = TRUE)

absolute_tifs_126 <- list.files(path = tif_path, pattern = "bin_change_ssp126", full.names = TRUE)
absolute_tifs_370 <- list.files(path = tif_path, pattern = "bin_change_ssp370", full.names = TRUE)
absolute_tifs_585 <- list.files(path = tif_path, pattern = "bin_change_ssp585", full.names = TRUE)

relative_tifs_126 <- list.files(path = tif_path, pattern = "cal_growth_rate_ssp126", full.names = TRUE)
relative_tifs_370 <- list.files(path = tif_path, pattern = "cal_growth_rate_ssp370", full.names = TRUE)
relative_tifs_585 <- list.files(path = tif_path, pattern = "cal_growth_rate_ssp585", full.names = TRUE)

# Observed period
absolute_tifs_observed <- list.files(path = tif_path, pattern = "bin_change_observed", full.names = TRUE)
relative_tifs_observed <- list.files(path = tif_path, pattern = "cal_growth_rate_observed", full.names = TRUE)