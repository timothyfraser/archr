# archr
Repository for setting up an R package for enumerating and analyzing system architectures.

Project Manager: Tim Fraser


Goal: Develop a Systems Architecting Platform for (1) SYSEN 5400, (2) Academic, (3) Commercial Tier, comprising two primary, interlinked tools:

1. `architect`: A dashboard for system architecture
2. `archr`: An R package for system architecture analysis

`archr` will take the user through several stages of analyses, with mirrored pages on the dashboard. These include:

`decisions` --> `enumerate` --> `prune` --> `evaluate` --> `compare`

Additional Requirements:

- `tidyverse` compatible, meaning it uses tidy `tibbles` wherever possible.
- As few dependencies as possible. Main dependencies will likely be `dplyr`, `stringr`, `readr`, and `tidyr`. Optionally could integrate with `igraph` and `tidygraph` for visualization.

Project Stages:

- Core Function Development
- `roxygen` Documentation
- Package Testing
- Vignette Development
- Package Deployment on Github, later CRAN
- Paper
- ShinyApp Design and Development
- ShinyApp Deployment
