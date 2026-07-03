library(glue)
library(tidyverse)

# ------------------------------------------------------------------------------
# Load data
# ------------------------------------------------------------------------------

rds_path <- "~/Documents/projects/project_Bcells/GC_B_cells/45_immcantation/out/rds"

rds_files <- list.files(rds_path) 
resolve_LC_files <- grep("resolve_LC_3_definitions", rds_files, value = TRUE)

patients <- lapply(resolve_LC_files, function(x) str_split_i(x, "_", 1)) %>% unlist()
patients

HH <- "HH119"

# Read rds
df <- readRDS(glue("{rds_path}/{HH}_resolve_LC_3_definitions.rds"))

# df$clone_subgroup_id_90_similarity

df_heavy <- df %>% filter(locus == "IGH") 
df_light <- df %>% filter(locus != "IGH") 

# ------------------------------------------------------------------------------
# Get clone sequence
# ------------------------------------------------------------------------------

# Define clone
clone_nr <- 1

# Top clone id
clone_id <- df_heavy
  count(clone_subgroup_id_90_similarity, sort = TRUE) %>% 
  slice(clone_nr) %>% 
  pull(clone_subgroup_id_90_similarity)

# and the most abundant unique heavy chain sequence of that clone
clone_sequence_heavy <- df_heavy %>% 
  filter(clone_subgroup_id_90_similarity == clone_id) %>% 
  count(sequence_alignment, sort = TRUE) %>% 
  slice(1) %>%
  pull(sequence_alignment)

# Find cells with this heavy chain sequence
clone_cell_id <- df_heavy %>% 
  filter(sequence_alignment == clone_sequence_heavy) %>% 
  pull(cell_id)

# Get light chain of these cells 
clone_sequence_light <- df_light %>% 
  filter(cell_id %in% clone_cell_id) %>% 
  count(sequence_alignment, sort = TRUE) %>% 
  slice(1) %>%
  pull(sequence_alignment)

# N cells in total with this combination of heavy and light chain sequence
df_light %>% 
  filter(
    cell_id %in% clone_cell_id, # Cells with given heavy chain 
    sequence_alignment == clone_sequence_light # Cells with given light chain 
  ) %>% 
  nrow()

# verify that heavy chain sequence is unique
df %>% filter(locus == "IGH", cell_id %in% clone_cell_id) %>% pull(sequence) %>% unique()

# ------------------------------------------------------------------------------
# Check gene usage of sequences
# ------------------------------------------------------------------------------

df_heavy %>% filter(sequence_alignment == clone_sequence_heavy) %>% pull(v_call_no_allele) %>% unique()
df_heavy %>% filter(sequence_alignment == clone_sequence_heavy) %>% pull(j_call_no_allele) %>% unique()

df_light %>% filter(sequence_alignment == clone_sequence_light) %>% pull(v_call_no_allele) %>% unique()
df_light %>% filter(sequence_alignment == clone_sequence_light) %>% pull(j_call_no_allele) %>% unique()

# ------------------------------------------------------------------------------
# Translate sequences from nt to aa
# ------------------------------------------------------------------------------

# remove gaps
clone_sequence_light_clean <- gsub("\\.", "", clone_sequence_light)
clone_sequence_heavy_clean <- gsub("\\.", "", clone_sequence_heavy)

# translate from nt to aa
clone_sequence_heavy_aa <- alakazam::translateDNA(c(clone_sequence_heavy_clean), trim = TRUE)
clone_sequence_light_aa <- alakazam::translateDNA(c(clone_sequence_light_clean), trim = TRUE)

# Check that junction is in sequence 
junciton_heavy_aa <- df_heavy %>% filter(sequence_alignment == clone_sequence_heavy) %>% pull(junction_aa) %>% unique()
str_detect(clone_sequence_heavy_aa, junciton_heavy_aa)

# Check that junction is in sequence 
junciton_light_aa <- df_light %>% filter(sequence_alignment == clone_sequence_light) %>% pull(junction_aa) %>% unique()
str_detect(clone_sequence_light_aa, junciton_light_aa)

# ------------------------------------------------------------------------------
# Export sequences
# ------------------------------------------------------------------------------

write_lines(clone_sequence_heavy_aa, glue("000_prepare/out/{HH}_clone_nr_{clone_nr}_id_{clone_id}_heavy.txt"))
write_lines(clone_sequence_light_aa, glue("000_prepare/out/{HH}_clone_nr_{clone_nr}_id_{clone_id}_light.txt"))




