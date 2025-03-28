######
# Script : Palmer Penguins data exploration
# Author: Sofía Zorrilla
# Date: 2025-03-19
# Description: 
# Arguments:
#   - Input: 
#   - Output: 
#######


# Load packages -----------------------------------------------------------

library(tidyverse)
library(rnaturalearth)
library(rnaturalearthdata)
library(palmerpenguins)
library(patchwork)
library(ggrepel)
library(GGally)


# Data --------------------------------------------------------------------

data("penguins")

# Coordenadas obtenidas a partir del artículo original (https://doi.org/10.1371/journal.pone.0090081)
coordinates <- data.frame(
  Island = c("Biscoe\nIsland", "Torgersen\nIsland", "Dream Island"),
  Latitude = c(-64.800, -64.767, -64.717),
  Longitude = c(-63.767, -64.067, -64.217)
)

# Sampling map ------------------------------------------------------------

# Get Antarctica and nearby islands data
antarctica <- ne_countries(scale = "medium", continent = "antarctica", returnclass = "sf")

# Main map (Antarctica)
main_map <- ggplot(data = antarctica) +
  geom_sf(fill = "gray90", color = "black") +
  theme_minimal() +
  geom_rect(
    xmin = -64.5, xmax = -63, ymin = -65, ymax = -64.2,
    color = "black", fill = NA, linewidth = 0.5
  ) +
  labs(title = "Sampling Sites in the Palmer Archipelago", x = "Longitude", y = "Latitude") +
  coord_sf(xlim = c(-95, -28), ylim = c(-78, -60)) +
  theme(
    axis.text = element_text(size = 8),
    plot.title = element_text(size = 12)
  )

# Inset map (Palmer Archipelago region)
inset_map <- ggplot(data = antarctica) +
  geom_sf(fill = "gray90", color = "black") +
  geom_point(data = coordinates, aes(x = Longitude, y = Latitude, color = Island), size = 3) +
  geom_text_repel(data = coordinates, aes(x = Longitude, y = Latitude, label = Island), 
            hjust = -0.1, vjust = 0.5, size = 3) +
  theme_bw()+
  theme(legend.position = "none",
        axis.text = element_blank(),
        axis.ticks = element_blank(), 
        axis.title = element_blank(),
        panel.border = element_rect(color = 'black', size = 1),
        panel.grid = element_blank()) +
  coord_sf(xlim = c(-64.5, -63), ylim = c(-65, -64.4)) +
  labs(x = "Longitude", y = "Latitude")

# Combine the main and inset map
final_map <- main_map +
  inset_element(inset_map,  left = 0.55,    # Start near the right side
                bottom = 0.10,  # Start close to the bottom
                right = 0.99,   # End near the right edge
                top = 0.75,      # End partway up from the bottom
                align_to = 'full')

# Display the map
final_map



# Sampling size table --------------------------------------------------------

# Sampling size
levels(penguins$sex) <- c("female", "male","Unkn.")
levels(penguins$species) <- c("P. adelie", "P. chinstrap", "P. gentoo")
penguins$sex[is.na(penguins$sex)] <- "Unkn."

library(kableExtra)

penguins %>% 
  # Summarize data by species, island, and sex
  summarise(n = n(), .by = c(species, island, sex)) %>% 
  
  # Convert count to character to allow empty string
  mutate(n = as.character(n)) %>% 
  
  # Reshape data to wide format
  pivot_wider(
    id_cols = c(species, island), 
    names_from = sex, 
    values_from = n, 
    values_fill = list(n = "")
  ) %>% 
  
  # Create kable table
  kbl(
    caption = "Summary of Penguin Counts by Species, Island, and Sex", 
    col.names = c("Species", "Island", "Male", "Female", "Unkn.")
  ) %>% 
  
  # Bold column labels
  kable_styling(
    full_width = FALSE, 
    bootstrap_options = c("striped", "hover"), 
    font_size = 14
  ) %>% 
  
  # Italicize species names in row groups
  column_spec(1, italic = TRUE)


# Visualization of variables per sex -------------------------------------

data(penguins)

penguins%>%
  filter(!is.na(sex)) %>%
  select(-c(island, year)) %>%
  ggpairs(
    columns = 2:5,
    mapping = aes(color = sex, fill = species), 
    upper = list(continuous = wrap("points", shape = 21, size = 2.5, mapping = aes( fill = sex), color = "black")),  
    diag = list(continuous = "blank"), 
    lower = list(continuous = wrap("points", size = 2.5, alpha = 0.8)) 
  ) +
  theme_bw() +
  labs(title = "Palmer Penguins: Morphological Measurements") +
  theme(legend.position = "bottom")
