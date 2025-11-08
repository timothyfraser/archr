#!/usr/bin/env python3
"""
Utility script to generate tutorial Rmd guides for every workshop script.
"""
from __future__ import annotations

from pathlib import Path
import textwrap


WORKSHOP_DIR = Path("/workspace/workshops")
GUIDE_DIR = Path("/workspace/guides")


def parse_meta(text: str) -> dict[str, str]:
    meta: dict[str, str] = {}
    for line in text.splitlines():
        stripped = line.lstrip()
        if not stripped.startswith("#"):
            break
        content = stripped.lstrip("#").strip()
        if ":" in content:
            key, value = content.split(":", 1)
            meta[key.strip().lower()] = value.strip()
    return meta


def detect_features(text: str) -> dict[str, bool]:
    lower = text.lower()
    install_packages = "install.packages" in lower
    library_present = "library(" in lower or "require(" in lower
    read_tokens = [
        "read_csv",
        "readr::read_csv",
        "readr::read_rds",
        "read.csv",
        "readr::read_tsv",
        "readr::read_delim",
        "write_csv",
        "write_rds",
        "readr::write",
    ]
    write_tokens = [
        "write_csv",
        "write_rds",
        "write_delim",
        "write.table",
        "save(",
        "save.image(",
    ]
    dplyr_tokens = [
        "mutate(",
        "summarize(",
        "summarise(",
        "select(",
        "filter(",
        "arrange(",
        "group_by(",
        "reframe(",
    ]
    apply_tokens = ["map(", "apply(", "lapply(", "sapply(", "purrr::", "vapply("]

    read_data = any(token in lower for token in read_tokens)
    write_data = any(token in lower for token in write_tokens)
    dplyr = "%>%" in text or "dplyr::" in text or any(token in lower for token in dplyr_tokens)
    ggplot = "ggplot(" in lower or "geom_" in lower
    function_def = "function(" in lower
    loops = "for (" in lower or "while (" in lower
    apply = any(token in lower for token in apply_tokens)
    ga = "ga(" in lower or "genetic" in lower

    return {
        "install_packages": install_packages,
        "library": library_present,
        "read_data": read_data,
        "write_data": write_data,
        "dplyr": dplyr,
        "ggplot": ggplot,
        "function_def": function_def,
        "loops": loops,
        "apply": apply,
        "ga": ga,
    }


def build_skills(meta: dict[str, str], features: dict[str, bool], script_name: str) -> list[str]:
    lines: list[str] = []
    section = meta.get("section", "workshop")
    lines.append(f"Navigate the script `{script_name}` within the {section} module.")

    topic = meta.get("topic")
    if topic:
        lines.append(f"Connect the topic \"{topic}\" to systems architecting decisions.")

    if features["install_packages"]:
        lines.append("Install any required packages highlighted with `install.packages()`.")
    if features["library"]:
        lines.append("Load packages with `library()` and verify they attach without warnings.")
    if features["read_data"]:
        lines.append("Import and export data files using `readr` helpers and inspect the results.")
    if features["dplyr"]:
        lines.append("Practice tidyverse pipelines (`%>%`) to transform stakeholder or architecture tables.")
    if features["function_def"]:
        lines.append("Define and call custom functions to encapsulate reusable logic.")
    if features["ggplot"]:
        lines.append("Create or interpret visualizations produced with `ggplot2`.")
    if features["loops"]:
        lines.append("Use control flow (such as `for` loops) to iterate over scenarios.")
    if features["apply"]:
        lines.append("Leverage `apply` and `purrr` tools to evaluate many design alternatives in one step.")
    if features["ga"]:
        lines.append("Explore optimization routines configured with the `GA` package.")

    if len(lines) < 3:
        lines.append("Document observations from running each code block in your lab notebook.")

    return lines


def build_application_steps(meta: dict[str, str], features: dict[str, bool], script_name: str) -> list[str]:
    steps: list[str] = []
    steps.append(
        f"Open `workshops/{script_name}` in the Source pane and skim the header comments for context."
    )
    steps.append(
        "Set your working directory to the project root so relative paths such as `workshops/` resolve correctly."
    )

    if features["install_packages"]:
        steps.append("Run any `install.packages()` lines once to make sure the dependencies exist on your machine.")
    if features["library"]:
        steps.append("Load the libraries listed near the top of the script and confirm they attach without errors.")
    if features["read_data"]:
        steps.append(
            "Walk through the data import and export chunks, using the Environment pane to inspect the created objects."
        )
    if features["dplyr"]:
        steps.append(
            "Execute each tidyverse pipeline slowly, pausing to read the intermediate tibbles that appear in the Console."
        )
    if features["function_def"]:
        steps.append("Re-run the custom functions with your own arguments to observe how the outputs change.")
    if features["ggplot"]:
        steps.append("Recreate the plotted visuals and experiment with aesthetic mappings to reinforce each layer.")
    if features["loops"]:
        steps.append("Trace through any loops to understand how iteration explores multiple stakeholder or design cases.")
    if features["apply"]:
        steps.append("Review `apply` and `map` examples and try swapping in a different input vector to test yourself.")
    if features["ga"]:
        steps.append(
            "Inspect the optimization configuration (population size, mutation rate) to see how they influence GA output."
        )

    steps.append(
        f"When you are comfortable, run `source(file.path(\"workshops\", \"{script_name}\"))` or click Source to execute the full workshop."
    )
    steps.append("Record key takeaways and questions in the Learning Checks section below.")

    return steps


def build_learning_checks(meta: dict[str, str], features: dict[str, bool], script_name: str) -> list[dict[str, str]]:
    topic = meta.get("topic", "this workshop")
    questions: list[dict[str, str]] = []

    def add(prompt: str, answer: str) -> None:
        questions.append({"prompt": prompt, "answer": answer})

    add(
        "How do you run the entire workshop script after you have stepped through each section interactively?",
        f"Use `source(file.path(\"workshops\", \"{script_name}\"))` from the Console or press the Source button while the script is active.",
    )

    if features["install_packages"] or features["library"]:
        add(
            "Why does the script begin by installing or loading packages before exploring the exercises?",
            "Those commands make sure the required libraries are available so every subsequent code chunk runs without missing-function errors.",
        )
    if features["read_data"]:
        add(
            "Which helper do you use in this workshop to bring external data into R, and what should you check right after calling it?",
            "Use the `readr` functions shown (such as `read_csv()` or `read_rds()`) and immediately inspect the resulting tibble in the Environment pane to confirm the columns loaded as expected.",
        )
    if features["dplyr"]:
        add(
            "What does the `%>%` pipeline operator help you accomplish in the worked examples?",
            "It passes the intermediate tibble from one tidyverse verb to the next so you can express multi-step transformations clearly and avoid temporary variables.",
        )
    if features["function_def"]:
        add(
            "How can you verify that a custom function defined in the script behaves the way you expect?",
            "Call the function with a simple input (for example the one used in the script) and print or view the returned value, then try a new input to see how the output changes.",
        )
    if features["ggplot"]:
        add(
            "When the script produces a `ggplot`, what experiment can you run to understand the mapping between data and aesthetics?",
            "Modify one aesthetic, such as switching `color` to `fill` or adjusting `geom_point()` size, and re-run the plot to see how visual encodings respond.",
        )
    if features["ga"]:
        add(
            "What GA configuration element should you review to understand how the optimization search proceeds?",
            "Check population size, mutation probability, and the fitness function definition because they drive how candidate architectures evolve.",
        )

    if len(questions) < 3:
        add(
            f"In your own words, what key idea does the topic \"{topic}\" reinforce?",
            f"It emphasizes how {topic.lower()} supports the overall systems architecting process in this course.",
        )
    if len(questions) < 3:
        add(
            "Where in the guide should you revisit if you need to recall prerequisite steps before re-running the code?",
            "Return to the Setup section to confirm the working directory, required packages, and project context before executing the scripts again.",
        )

    return questions[:5]


def build_document(script_path: Path) -> str:
    script_name = script_path.name
    content = script_path.read_text(encoding="utf-8")
    meta = parse_meta(content)
    features = detect_features(content)

    skills = build_skills(meta, features, script_name)
    application_steps = build_application_steps(meta, features, script_name)
    checks = build_learning_checks(meta, features, script_name)

    number = script_name.split("_")[0]
    title_topic = meta.get("topic")

    if title_topic:
        title_text = f"[{number}] {title_topic} Guide"
    else:
        title_text = f"[{number}] {script_name} Guide"

    intro_lines: list[str] = []
    topic_line = meta.get("topic")
    if topic_line:
        intro_lines.append(
            f"This tutorial complements `{script_name}` and unpacks the workshop on {topic_line.lower()}."
        )
    else:
        intro_lines.append(
            f"This tutorial complements `{script_name}` and walks you through the workshop script step by step."
        )

    section_line = meta.get("section")
    if section_line:
        intro_lines.append(
            f"You will see how it advances the {section_line} sequence while building confidence with base R and tidyverse tooling."
        )
    else:
        intro_lines.append("Use it to reinforce each concept before moving on to the next exercise.")

    intro = " ".join(intro_lines)

    skills_block = "\n".join(f"- {line}" for line in skills)
    application_block = "\n".join(f"{idx}. {line}" for idx, line in enumerate(application_steps, start=1))

    learning_block_parts: list[str] = []
    for idx, item in enumerate(checks, start=1):
        learning_block_parts.append(f"**Learning Check {idx}.** {item['prompt']}")
        learning_block_parts.append(
            "\n<details>\n<summary>Show answer</summary>\n\n"
            + item["answer"]
            + "\n\n</details>\n"
        )
    learning_block = "\n".join(learning_block_parts).strip() + "\n"

    front_matter = textwrap.dedent(
        f"""\
        ---
        title: "{title_text}"
        output:
          md_document:
            variant: gfm
        output_dir: ../workshops
        knitr:
          opts_knit:
            root.dir: ..
        ---
        """
    ).strip()

    body = (
        f"{intro}\n\n"
        "## Setup\n\n"
        "- Ensure you have opened the `archr` project root (or set your working directory there) before running any code.\n"
        "- Open the workshop script in RStudio so you can execute lines interactively with `Ctrl+Enter` or `Cmd+Enter`.\n"
        "- Create a fresh R session to avoid conflicts with leftover objects from earlier workshops.\n\n"
        "## Skills\n\n"
        f"{skills_block}\n\n"
        "## Application\n\n"
        f"{application_block}\n\n"
        "## Learning Checks\n\n"
        f"{learning_block}"
    ).strip()

    return front_matter + "\n\n" + body + "\n"


def main() -> None:
    GUIDE_DIR.mkdir(exist_ok=True)
    for script_path in sorted(WORKSHOP_DIR.glob("*.R")):
        guide_name = f"[{script_path.name.split('_')[0]}]_[{script_path.name}]_guide.Rmd"
        guide_path = GUIDE_DIR / guide_name
        guide_path.write_text(build_document(script_path), encoding="utf-8")


if __name__ == "__main__":
    main()
