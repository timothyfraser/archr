#!/usr/bin/env python3
"""
Generate step-by-step R Markdown guides for every workshop script.
"""

from __future__ import annotations

import re
import textwrap
from dataclasses import dataclass
from pathlib import Path


WORKSHOP_DIR = Path("/workspace/workshops")
GUIDE_DIR = Path("/workspace/guides")

META_PREFIXES = (
    "script:",
    "original:",
    "topic:",
    "section:",
    "developed by:",
    "@name",
    "@title",
    "@description",
)


@dataclass
class Step:
    title: str
    description: str
    code: list[str]


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

    return {
        "install_packages": "install.packages" in lower,
        "library": "library(" in lower or "require(" in lower,
        "read_data": any(token in lower for token in read_tokens),
        "write_data": any(token in lower for token in write_tokens),
        "dplyr": "%>%" in text or "dplyr::" in text or any(token in lower for token in dplyr_tokens),
        "ggplot": "ggplot(" in lower or "geom_" in lower,
        "function_def": "function(" in lower,
        "loops": "for (" in lower or "while (" in lower,
        "apply": any(token in lower for token in apply_tokens),
        "ga": "ga(" in lower or "genetic" in lower,
    }


def normalise_space(text: str) -> str:
    return re.sub(r"\s+", " ", text.strip())


def ensure_sentence(text: str) -> str:
    if not text:
        return ""
    text = text.strip()
    if text and text[-1] not in ".!?":
        text += "."
    return text


def title_case(text: str) -> str:
    words = re.split(r"[\s_-]+", text.strip())
    return " ".join(word.capitalize() for word in words if word)


def infer_step_metadata(code_lines: list[str]) -> tuple[str, str]:
    first_code = ""
    for line in code_lines:
        stripped = line.strip()
        if not stripped:
            continue
        if stripped.startswith("#"):
            continue
        first_code = stripped
        break

    if not first_code:
        return ("Review This Code", "Run the code block and observe the output.")

    lower = first_code.lower()

    def extract_packages(pattern: str) -> str:
        matches = re.findall(pattern, first_code)
        return ", ".join(matches)

    if "install.packages" in lower:
        pkgs = extract_packages(r'install\.packages\((?:c\()?(?P<pkg>[^)]+)\)')
        pkg_names = re.findall(r'"([^"]+)"', pkgs) or re.findall(r"'([^']+)'", pkgs)
        pkg_text = ", ".join(pkg_names) if pkg_names else "the listed packages"
        return ("Install Packages", f"Install {pkg_text} so the rest of the workshop can run.")

    if lower.startswith("library(") or lower.startswith("require("):
        pkg = re.findall(r"(?:library|require)\(([^)]+)\)", first_code)
        pkg_text = pkg[0].strip() if pkg else "the package"
        return ("Load Packages", f"Attach {pkg_text} to make its functions available.")

    if "credentials::set_github_pat" in lower:
        return ("Register GitHub PAT", "Store your GitHub personal access token securely using the credentials package.")

    if "readr::read_csv" in lower or "read_csv(" in lower:
        file_match = re.findall(r'\"([^\"]+\.csv)\"', first_code)
        file_text = file_match[0] if file_match else "the CSV file"
        return ("Import CSV Data", f"Load {file_text} into a tibble you can explore in R.")

    if "readr::read_rds" in lower or "read_rds(" in lower or "readr::read_rds" in lower:
        file_match = re.findall(r'\"([^\"]+\.rds)\"', first_code)
        file_text = file_match[0] if file_match else "the RDS file"
        return ("Import RDS Data", f"Read {file_text} so you can inspect the stored objects.")

    if "write_csv(" in lower or "readr::write_csv" in lower:
        file_match = re.findall(r'\"([^\"]+\.csv)\"', first_code)
        file_text = file_match[0] if file_match else "a CSV file"
        return ("Save Data to CSV", f"Export a tibble to {file_text} for later use.")

    if "write_rds(" in lower or "readr::write_rds" in lower:
        file_match = re.findall(r'\"([^\"]+\.rds)\"', first_code)
        file_text = file_match[0] if file_match else "an RDS file"
        return ("Save Data to RDS", f"Store an object as {file_text} to preserve its structure.")

    func_match = re.search(r"(\w+)\s*(?:<-|=)\s*function\s*\(", first_code)
    if func_match:
        func_name = func_match.group(1)
        return (f"Define `{func_name}()`", f"Create the helper function `{func_name}()` so you can reuse it throughout the workshop.")

    if lower.startswith("function("):
        return ("Define a Function", "Declare an inline function you can use immediately in the pipeline.")

    if "%>%" in first_code:
        return ("Practice the Pipe", "Use the `%>%` operator to pass each result to the next tidyverse verb.")

    if lower.startswith("ggplot("):
        return ("Start a ggplot", "Initialize a ggplot so you can layer geoms and customise aesthetics.")

    if lower.startswith("data.frame(") or lower.startswith("tibble("):
        return ("Build a Data Frame", "Construct a small data frame that you can manipulate later.")

    if lower.startswith("matrix("):
        return ("Create a Matrix", "Create a matrix to practice element-wise and matrix operations.")

    if lower.startswith("rm(") or "rm(" in lower:
        return ("Clear Objects", "Remove objects from the environment to prevent name clashes.")

    if lower.startswith("remove("):
        return ("Remove Objects", "Delete specific objects so you can redefine them cleanly.")

    if lower.startswith("for ") or lower.startswith("for("):
        return ("Loop Through Values", "Iterate over values to apply the same logic to each item.")

    if re.match(r"[0-9\.\s\+\-\*/()]+$", first_code):
        return ("Try Arithmetic", "Evaluate a quick arithmetic expression to observe R's console output.")

    assign_match = re.match(r"([\w\.]+)\s*(?:<-|=)", first_code)
    if assign_match:
        var_name = assign_match.group(1)
        return (f"Create `{var_name}`", f"Create the object `{var_name}` so you can reuse it in later steps.")

    return ("Run the Code Block", "Execute the block and pay attention to the output it produces.")


def description_needs_more(text: str) -> bool:
    return len(text.split()) < 4


def derive_title_from_description(description: str) -> str | None:
    if not description:
        return None
    sentence = description.split(".")[0]
    if not sentence:
        return None
    return title_case(sentence)


def extract_steps(text: str) -> list[Step]:
    steps: list[Step] = []
    desc_buffer: list[str] = []
    code_buffer: list[str] = []

    def flush_step() -> None:
        nonlocal desc_buffer, code_buffer
        if not code_buffer:
            desc_buffer = []
            return

        comment_text = normalise_space(" ".join(desc_buffer))
        title_guess, auto_desc = infer_step_metadata(code_buffer)

        description = comment_text
        if description and description_needs_more(description):
            description = ensure_sentence(description) + " " + ensure_sentence(auto_desc)
        elif description:
            description = ensure_sentence(description)
        else:
            description = ensure_sentence(auto_desc)

        title = title_guess or derive_title_from_description(comment_text) or "Workshop Step"

        steps.append(
            Step(
                title=title,
                description=description,
                code=list(code_buffer),
            )
        )
        desc_buffer = []
        code_buffer = []

    for raw_line in text.splitlines():
        stripped = raw_line.strip()

        if stripped == "":
            flush_step()
            continue

        if stripped.startswith("#'"):
            continue

        if stripped.startswith("#"):
            comment = stripped.lstrip("#").strip()
            if code_buffer:
                code_buffer.append(raw_line)
            else:
                if comment and not comment.lower().startswith(META_PREFIXES):
                    desc_buffer.append(comment)
            continue

        code_buffer.append(raw_line)

    flush_step()
    return steps


def comment_startswith(prefixes: tuple[str, ...], text: str) -> bool:
    lower = text.lower()
    return any(lower.startswith(prefix) for prefix in prefixes)


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
        lines.append("Import data files with `readr` helpers and inspect the resulting objects.")
    if features["write_data"]:
        lines.append("Export results to disk so you can reuse them across workshops.")
    if features["dplyr"]:
        lines.append("Chain tidyverse verbs with `%>%` to explore stakeholder or architecture tables.")
    if features["function_def"]:
        lines.append("Define custom functions to package repeatable logic.")
    if features["ggplot"]:
        lines.append("Iterate on visualisations built with `ggplot2`.")
    if features["loops"]:
        lines.append("Use loops to explore multiple scenarios quickly.")
    if features["apply"]:
        lines.append("Leverage `apply`/`purrr` tools for vectorised evaluations.")
    if features["ga"]:
        lines.append("Experiment with optimisation searches powered by the `GA` package.")

    if len(lines) < 3:
        lines.append("Document observations from running each code block in your lab notebook.")

    return lines


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
            "When you import data in this workshop, what should you inspect right after the read call?",
            "Check the tibble in the Environment pane (or print it) to confirm column names and types look correct.",
        )
    if features["dplyr"]:
        add(
            "How does the `%>%` pipeline help you reason about multi-step transformations in this script?",
            "It keeps each operation in sequence without creating temporary variables, so you can narrate the data story line by line.",
        )
    if features["function_def"]:
        add(
            "How can you build confidence that a newly defined function behaves as intended?",
            "Call it with the sample input from the script, examine the output, then try a new input to see how the behaviour changes.",
        )
    if features["ggplot"]:
        add(
            "What experiment can you run on the `ggplot` layers to understand how aesthetics map to data?",
            "Switch one aesthetic (for example `color` to `fill` or tweak the geometry) and re-run the chunk to observe the difference.",
        )
    if features["ga"]:
        add(
            "Which GA configuration elements should you review after running the optimisation example?",
            "Check the population size, mutation probability, and fitness function definition to understand how the search explores designs.",
        )

    if len(questions) < 3:
        add(
            f"In your own words, what key idea does the topic \"{topic}\" reinforce?",
            f"It highlights how {topic.lower()} supports the overall systems architecting process in this course.",
        )
    if len(questions) < 3:
        add(
            "Where should you look if you need to reset your setup before re-running the script?",
            "Return to the Setup section to confirm your working directory, packages, and clean R session.",
        )

    return questions[:5]


def build_application_section(steps: list[Step]) -> str:
    parts: list[str] = []
    for idx, step in enumerate(steps, start=1):
        chunk_label = f"step_{idx:02d}"
        code_body = "\n".join(step.code).rstrip()
        block_lines = [
            f"### Step {idx} – {step.title}",
            "",
            step.description,
            "",
            f"```{{r {chunk_label}, eval=FALSE}}",
            code_body,
            "```",
        ]
        parts.append("\n".join(block_lines).strip())
    return "\n\n".join(parts)


def build_document(script_path: Path) -> str:
    script_name = script_path.name
    content = script_path.read_text(encoding="utf-8")
    meta = parse_meta(content)
    features = detect_features(content)
    steps = extract_steps(content)

    if not steps:
        steps = [
            Step(
                title="Review the Script",
                description="Read through the script and experiment with each line in the console.",
                code=[content.strip()],
            )
        ]

    skills = build_skills(meta, features, script_name)
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

    application_block = build_application_section(steps)

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
