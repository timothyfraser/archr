# Script: 10_architecting_ahp_archr_demo.R
# Original: lecture_3.R
# Topic: AHP with archr demo
# Section: Architecting Systems
# Developed by: Timothy Fraser, PhD
# lecture_3.R
# AHP and archr demo


# install.packages("nameofpackage.tar.gz", type = "source")

# Install it
install.packages("workshops/archr_1.0.tar.gz", type = "source")

# Load the archr package
library(archr)
library(dplyr)
library(readr)

# Use archr's get_sheet function
url_alt = get_sheet(
  docid = "1oLixfbnuep9p3purhJUDSdyW6YeGbXaujk6gU1ibaGg", 
  gid = "0")

url_cri = get_sheet(
  docid = "1oLixfbnuep9p3purhJUDSdyW6YeGbXaujk6gU1ibaGg",
  gid = "837220618"
)


alts = url_alt %>% read_csv()
cri = url_cri %>% read_csv()
alts
cri


alts %>% head(5)
alts %>% slice(1:5)


ahp = get_ahp(
  alternatives = alts,
  criteria = cri)

ahp$summary
ahp$consistency
