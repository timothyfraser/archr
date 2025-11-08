# Systems Architecture with `archr`

The `archr` repository underpins Cornell's Systems Architecture graduate coursework taught by Oliver Gao. It combines an installable R package with an extensive catalog of numbered workshops that guide students from stakeholder engagement through optimization. Coding workshops and the package were created by **Timothy Fraser, PhD**, whose materials are preserved and expanded here for future cohorts.

## Repository Layout
- `archr_package/` – the full R package source, documentation, data, and build artefacts.
- `docs/` – public-facing documentation excerpts.
- `workshops/` – course labs and case studies, now sequentially numbered for easier navigation.

## Shared Workshop Utilities
- [00_entropy_utilities.R](https://github.com/timothyfraser/archr/blob/v2/workshops/00_entropy_utilities.R) — entropy and information-gain helpers (`h`, `i`, `j`, `ig`).
- [00_pareto_rank_utilities.R](https://github.com/timothyfraser/archr/blob/v2/workshops/00_pareto_rank_utilities.R) — Pareto ranking helpers used across evaluation tutorials.
- [00_sensitivity_connectivity_utilities.R](https://github.com/timothyfraser/archr/blob/v2/workshops/00_sensitivity_connectivity_utilities.R) — reusable sensitivity and connectivity functions.

## Workshops by Topic

### Stakeholder Analysis
- [01_stakeholder_github_setup.R](https://github.com/timothyfraser/archr/blob/v2/workshops/01_stakeholder_github_setup.R) — onboarding to GitHub and collaborative workflows for the course.
- [02_stakeholder_package_setup.R](https://github.com/timothyfraser/archr/blob/v2/workshops/02_stakeholder_package_setup.R) — installs and verifies the R toolchain needed for `archr`.
- [03_stakeholder_first_r_script.R](https://github.com/timothyfraser/archr/blob/v2/workshops/03_stakeholder_first_r_script.R) — first steps writing and running an R script.
- [04_stakeholder_r_basics_workshop.R](https://github.com/timothyfraser/archr/blob/v2/workshops/04_stakeholder_r_basics_workshop.R) — Workshop 1 covering R objects, data wrangling, and tidy pipelines.
- [05_stakeholder_network_analysis_demo.R](https://github.com/timothyfraser/archr/blob/v2/workshops/05_stakeholder_network_analysis_demo.R) — stakeholder network modeling with `archr` graph utilities.

### Architecting Systems
- [06_architecting_dashboard_case_study.R](https://github.com/timothyfraser/archr/blob/v2/workshops/06_architecting_dashboard_case_study.R) — dashboard architecture case study focused on cost modeling.
- [07_architecting_conditional_logic_examples.R](https://github.com/timothyfraser/archr/blob/v2/workshops/07_architecting_conditional_logic_examples.R) — conditional logic patterns for architecture decisions.
- [08_architecting_metric_design.R](https://github.com/timothyfraser/archr/blob/v2/workshops/08_architecting_metric_design.R) — builds cost, benefit, and reliability metrics on enumerated architectures.
- [09_architecting_cost_function_examples.R](https://github.com/timothyfraser/archr/blob/v2/workshops/09_architecting_cost_function_examples.R) — modeling and projecting architecture cost functions.
- [10_architecting_ahp_archr_demo.R](https://github.com/timothyfraser/archr/blob/v2/workshops/10_architecting_ahp_archr_demo.R) — analytic hierarchy process (AHP) workflow using `archr`.
- [11_architecting_simple_counting_function.R](https://github.com/timothyfraser/archr/blob/v2/workshops/11_architecting_simple_counting_function.R) — recitation illustrating roxygen documentation and counting helpers.

### Enumeration
- [12_enumeration_scenarios.R](https://github.com/timothyfraser/archr/blob/v2/workshops/12_enumeration_scenarios.R) — scenario-based enumeration examples with `enumerate_*` helpers.
- [13_enumeration_sample_sizing.R](https://github.com/timothyfraser/archr/blob/v2/workshops/13_enumeration_sample_sizing.R) — minimum sample size calculations for main-effect studies.
- [14_enumeration_foundations.R](https://github.com/timothyfraser/archr/blob/v2/workshops/14_enumeration_foundations.R) — introductory enumeration tutorial and warm-up exercises.
- [15_enumeration_structures.R](https://github.com/timothyfraser/archr/blob/v2/workshops/15_enumeration_structures.R) — extending enumeration foundations to richer structures.
- [16_enumeration_constraints.R](https://github.com/timothyfraser/archr/blob/v2/workshops/16_enumeration_constraints.R) — applying architectural constraints during enumeration.
- [17_enumeration_sampling_strategies.R](https://github.com/timothyfraser/archr/blob/v2/workshops/17_enumeration_sampling_strategies.R) — sampling strategies for large enumerated design spaces.
- [18_enumeration_visualization.R](https://github.com/timothyfraser/archr/blob/v2/workshops/18_enumeration_visualization.R) — visual storytelling with enumerated architectures (includes PNG assets).
- [19_enumeration_filters.R](https://github.com/timothyfraser/archr/blob/v2/workshops/19_enumeration_filters.R) — filtering workflows for targeted architecture sets.
- [20_enumeration_custom_metrics.R](https://github.com/timothyfraser/archr/blob/v2/workshops/20_enumeration_custom_metrics.R) — crafting bespoke metrics on enumerated alternatives.
- [21_enumeration_capstone.R](https://github.com/timothyfraser/archr/blob/v2/workshops/21_enumeration_capstone.R) — capstone lab combining enumeration concepts.

### Evaluation
- [22_evaluation_failure_rates.R](https://github.com/timothyfraser/archr/blob/v2/workshops/22_evaluation_failure_rates.R) — reliability primer on failure rates and lifespans.
- [23_evaluation_learning_curves.R](https://github.com/timothyfraser/archr/blob/v2/workshops/23_evaluation_learning_curves.R) — modeling learning curves for system performance.
- [24_evaluation_monte_carlo.R](https://github.com/timothyfraser/archr/blob/v2/workshops/24_evaluation_monte_carlo.R) — Monte Carlo simulation techniques for risk evaluation.
- [25_evaluation_net_present_value.R](https://github.com/timothyfraser/archr/blob/v2/workshops/25_evaluation_net_present_value.R) — net present value calculations and visualization.
- [26_evaluation_system_reliability.R](https://github.com/timothyfraser/archr/blob/v2/workshops/26_evaluation_system_reliability.R) — system reliability modeling and series failures.
- [27_evaluation_utility_functions.R](https://github.com/timothyfraser/archr/blob/v2/workshops/27_evaluation_utility_functions.R) — single- and multi-attribute utility modeling.
- [28_evaluation_pareto_fronts.R](https://github.com/timothyfraser/archr/blob/v2/workshops/28_evaluation_pareto_fronts.R) — exploring Pareto fronts and frontier visualization.
- [29_evaluation_risk_modeling.R](https://github.com/timothyfraser/archr/blob/v2/workshops/29_evaluation_risk_modeling.R) — tutorial on risk modeling for donut delivery systems.
- [30_evaluation_probability_practice.R](https://github.com/timothyfraser/archr/blob/v2/workshops/30_evaluation_probability_practice.R) — probability practice set supporting evaluation skills.
- [31_evaluation_probability_solutions.R](https://github.com/timothyfraser/archr/blob/v2/workshops/31_evaluation_probability_solutions.R) — solution key for the probability practice workshop.
- [32_evaluation_scenarios.R](https://github.com/timothyfraser/archr/blob/v2/workshops/32_evaluation_scenarios.R) — scenario evaluation exercises exploring trade-offs.
- [33_evaluation_metric_design.R](https://github.com/timothyfraser/archr/blob/v2/workshops/33_evaluation_metric_design.R) — designing and weighting evaluation metrics.
- [34_evaluation_storytelling.R](https://github.com/timothyfraser/archr/blob/v2/workshops/34_evaluation_storytelling.R) — communicating evaluation results through graphics and narrative.
- [35_evaluation_tradespace_intro.R](https://github.com/timothyfraser/archr/blob/v2/workshops/35_evaluation_tradespace_intro.R) — introduction to tradespace analysis with enumerated data.
- [36_evaluation_tradespace_visuals.R](https://github.com/timothyfraser/archr/blob/v2/workshops/36_evaluation_tradespace_visuals.R) — tradespace visualization techniques.
- [37_evaluation_main_effects_lab.R](https://github.com/timothyfraser/archr/blob/v2/workshops/37_evaluation_main_effects_lab.R) — main-effects lab for tradespace interpretation.
- [38_evaluation_recitation_main_effects.R](https://github.com/timothyfraser/archr/blob/v2/workshops/38_evaluation_recitation_main_effects.R) — recitation walkthrough of main-effects analysis.
- [39_evaluation_pareto_prioritization.R](https://github.com/timothyfraser/archr/blob/v2/workshops/39_evaluation_pareto_prioritization.R) — prioritizing architectures with Pareto ranks and visuals.
- [40_evaluation_entropy_insights.R](https://github.com/timothyfraser/archr/blob/v2/workshops/40_evaluation_entropy_insights.R) — applying entropy and information gain to tradespace filtering.
- [41_evaluation_sensitivity_connectivity_lab.R](https://github.com/timothyfraser/archr/blob/v2/workshops/41_evaluation_sensitivity_connectivity_lab.R) — sensitivity and connectivity lab mirroring lecture content.

### Optimization
- [42_optimization_binary_encoding.R](https://github.com/timothyfraser/archr/blob/v2/workshops/42_optimization_binary_encoding.R) — binary encoding primer for optimization problems.
- [43_optimization_bit_integer_conversion.R](https://github.com/timothyfraser/archr/blob/v2/workshops/43_optimization_bit_integer_conversion.R) — bit-to-integer conversion utilities for genetic algorithms.
- [44_optimization_exercise_equipment_case.R](https://github.com/timothyfraser/archr/blob/v2/workshops/44_optimization_exercise_equipment_case.R) — exercise equipment optimization case study.
- [45_optimization_transportation_case.R](https://github.com/timothyfraser/archr/blob/v2/workshops/45_optimization_transportation_case.R) — Tompkins County transportation policy optimization.
- [46_optimization_time_series_case.R](https://github.com/timothyfraser/archr/blob/v2/workshops/46_optimization_time_series_case.R) — extending optimization across time-varying objectives.
- [47_optimization_green_space_case.R](https://github.com/timothyfraser/archr/blob/v2/workshops/47_optimization_green_space_case.R) — community green space optimization with entropy and sensitivity lenses.
- [48_optimization_parking_garage_case.R](https://github.com/timothyfraser/archr/blob/v2/workshops/48_optimization_parking_garage_case.R) — parking garage net-present-value optimization under uncertainty.
- [49_optimization_genetic_algorithms_intro.R](https://github.com/timothyfraser/archr/blob/v2/workshops/49_optimization_genetic_algorithms_intro.R) — introduction to genetic algorithms and `rmoo`.
- [50_optimization_multiobjective.R](https://github.com/timothyfraser/archr/blob/v2/workshops/50_optimization_multiobjective.R) — multiobjective optimization workflows.
- [51_optimization_advanced_search.R](https://github.com/timothyfraser/archr/blob/v2/workshops/51_optimization_advanced_search.R) — advanced search and crossover tactics.
- [52_optimization_feature_experiments.R](https://github.com/timothyfraser/archr/blob/v2/workshops/52_optimization_feature_experiments.R) — sandbox for experimenting with optimization feature ideas.

---

For questions on course delivery or contributions, coordinate with Oliver Gao. For historical context and workshop authorship, please credit Timothy Fraser, PhD. Pull requests should target new branches so course instructors can review updates before merging.
