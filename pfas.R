library(tidyverse)
library(here)
library(glue)
library(sf)
library(rajudas)
library(jsonlite)
library(readxl)
library(mapview)

# data --------------------------------------------------------------------
path_data = here("data_raw/pfas/PFAS in Donau und Zubringern mit Koordinaten.xlsx")

# coords
data_coords = read_xlsx(path_data, sheet = "coordinates", skip = 1) %>% janitor::clean_names()

#pfas
data_pfas_raw = read_xlsx(path_data, sheet = "sw_with_loq")

# data with coords
data = data_pfas_raw %>%
  select(-1) %>%
  filter(!row_number()  %in% c(1:3)) %>%
  janitor::clean_names() %>%
  mutate(across(pfba:n_et_fose, as.numeric)) %>%
  pivot_longer(
   cols=pfba:n_et_fose,
   names_to = "pfas_type",
   values_to = "vals"
  ) %>% left_join(data_coords) %>%
  st_as_sf(coords = c("longitude", "latitude"), crs = 4326)


data %>%
  filter(sample=="Alz") %>%
  filter(pfas_type == "adona") %>%
  st_drop_geometry() -> adona_alz

op_adona_alz = makePath(here("output/data/pfas/adona_alz.csv"))
write_csv(adona_alz, op_adona_alz)
