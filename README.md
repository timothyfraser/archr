# archr

## About `archr` 

- R Package for System Architecture Enumeration, Evaluation, and Optimization!
- Course Repository for SYSEN 5400. 
- Author: Tim Fraser, PhD

## Installing `archr`

To install `archr`, you will need the file `archr_1.0.tar.gz`, located in the main directory of this repository.

```
# First, pull the most recent version of this repository from github.
# Second, set your working directory to be this /archr repository
# For example:
setwd("~/archr")
# Third, check your working directory; make sure it actually is /archr
getwd()
# Fourth, Unload archr and remove the package, if you have already installed it.
unloadNamespace("archr"); remove.packages("archr")
# Fifth, install the package from source!
install.packages("archr_1.0.tar.gz", type = "source")
# That's it!
```

To load `archr`, once you have finished installing it, use the following commands in `R` to load the package.

```
# Finally, load archr!
library(archr)
# I'd also recommend loading the libraries it frequently uses, just in case:
library(dplyr)
library(readr)
library(tidyr)
library(ggplot2)
```



## `archr` development

Details:

- `tidyverse` compatible, meaning it uses tidy `tibbles` wherever possible.
- As few dependencies as possible. Main dependencies will likely be `dplyr`, `stringr`, `readr`, and `tidyr`. Optionally could integrate with `igraph` and `tidygraph` for visualization.

Next Steps: 

- Core Function Development
- `roxygen` Documentation
- Package Testing
- Vignette Development