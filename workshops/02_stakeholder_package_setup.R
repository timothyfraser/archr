# Script: 02_stakeholder_package_setup.R
# Original: packages_installed.R
# Topic: R package installation checklist
# Section: Stakeholder Analysis
# Developed by: Timothy Fraser, PhD
# List of packages installed
install.packages(c(
  # data wrangling packages
  "dplyr", "readr", "tidyr", "stringr", "purrr", 
  # networks packages
  "igraph", "tidygraph", "ggraph", 
  # Visualization packages
  "ggplot2", "viridis", "ggpubr",
  # Optimization support packages
  "GA", "rmoo",
  # Modeling support packages
  "texreg", "broom",
  # Extra helper packages
  "gtools"))
