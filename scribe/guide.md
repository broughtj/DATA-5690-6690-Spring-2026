# DATA 5690/6690 Scribe Notes — Student Guide

This guide explains how to write your scribe notes using the provided Quarto template. The output is a PDF that matches the course's standard format.

---

## Prerequisites

You need **Quarto** and a **LaTeX distribution** installed on your machine.

1. **Install Quarto:** Download from [quarto.org](https://quarto.org/docs/get-started/)
2. **Install LaTeX:** If you don't already have one, the easiest option is TinyTeX, which Quarto can install for you:
   ```bash
   quarto install tinytex
   ```
   Alternatively, install [TeX Live](https://tug.org/texlive/) (Linux/Windows) or [MacTeX](https://www.tug.org/mactex/) (macOS).

---

## Getting Started

You will receive a folder containing three files. Keep them together in the same directory.

```
your_folder/
├── scribe_template.qmd   ← your working file
├── scribe_styles.css     ← do not edit
└── guide.md              ← this file
```

Open `scribe_template.qmd` in any text editor (VS Code with the Quarto extension is recommended).

---

## Step 1 — Fill in the Lecture Information

At the very top of the file, inside the `---` block, update the four metadata fields:

```yaml
lecture-number: "3"
lecture-title: "Lecture 3: Entropy, Relative Entropy, and Mutual Information"
scribes: "Your Name, Collaborator Name"
lecture-date: "01/13/2015"
```

Then scroll down to the first code block (just below the `<!-- LECTURE HEADER -->` comment) and update the same information there:

```
\lecturetitle{3}{Lecture 3: Your Title Here}{Your Name, Collaborator Name}{01/13/2015}
```

The arguments are: `{lecture number}`, `{full title}`, `{scribe names}`, `{date}`.

> Both places must be kept in sync. The YAML fields are for reference; the `\lecturetitle` line is what appears in the rendered header box.

---

## Step 2 — Write Your Notes

Below the header block, write your notes in standard Markdown.

### Sections and subsections

```markdown
# Section Title

## Subsection Title
```

Sections are numbered automatically.

### Inline and display math

Use standard LaTeX math syntax. Quarto renders it via MathJax (HTML) or native LaTeX (PDF).

```markdown
The entropy is $H(U) \triangleq \E[s(U)]$.

$$
H(U) = \sum_{u \in \mathcal{U}} p(u) \log \frac{1}{p(u)}
$$
```

### Footnotes

```markdown
In this lecture^[*Reading:* Chapter 2 of Cover and Thomas.], we will...
```

### Bold and italic emphasis

```markdown
**Jensen's Inequality:** Let $Q$ be a *convex* function...
```

---

## Step 3 — Use Theorem Environments

All theorem-like environments (definitions, theorems, lemmas, etc.) are written as **raw LaTeX blocks**. The syntax is:

````
```{=latex}
\begin{ENVIRONMENT}
Content goes here.
\end{ENVIRONMENT}
```
````

Replace `ENVIRONMENT` with any of the following:

| Environment    | Output label         |
|----------------|----------------------|
| `definition`   | **Definition N.**    |
| `theorem`      | **Theorem N.**       |
| `lemma`        | **Lemma N.**         |
| `corollary`    | **Corollary N.**     |
| `proposition`  | **Proposition N.**   |
| `claim`        | **Claim N.**         |
| `fact`         | **Fact N.**          |
| `observation`  | **Observation N.**   |
| `assumption`   | **Assumption N.**    |
| `example`      | **Example N.**       |
| `exercise`     | **Exercise N.**      |

All environments share a single counter, so numbering is consecutive across the whole document.

You can optionally give a theorem a title in brackets:

````
```{=latex}
\begin{theorem}[Chain Rule for Entropy]
$H(X, Y) = H(X) + H(Y \mid X)$
\end{theorem}
```
````

### Proofs

````
```{=latex}
\begin{proof}
Your proof here. The $\square$ symbol is added automatically.
\end{proof}
```
````

Other proof variants: `proof-sketch`, `proof-idea`, `proof-attempt`.

### Remarks

````
```{=latex}
\begin{remark}
A note about the above result.
\end{remark}
```
````

---

## Step 4 — Available Math Macros

The following shorthand commands are defined for you:

| Command | Output |
|---|---|
| `\N`, `\R`, `\Z` | $\mathbb{N}$, $\mathbb{R}$, $\mathbb{Z}$ |
| `\E` | $\operatorname{E}$ (expectation) |
| `\PR` | $\operatorname{P}$ (probability) |
| `\norm{x}` | $\lVert x \rVert$ |
| `\card{x}` | $\lvert x \rvert$ |
| `\set{x}` | $\{x\}$ (auto-sized braces) |
| `\half` | $\frac{1}{2}$ |
| `\argmin`, `\argmax` | $\operatorname*{arg\,min}$, $\operatorname*{arg\,max}$ |
| `\minimize`, `\maximize` | display-style operators |
| `\I{condition}` | $\mathbb{I}_{\{condition\}}$ (indicator) |
| `\Pr{A}` | $\mathrm{Pr}[A]$ |
| `\Exp{X}` | $\mathrm{Exp}[X]$ |
| `\subjectto` | $\operatorname{subject\ to}$ |

---

## Step 5 — Render to PDF

In your terminal, navigate to the folder and run:

```bash
quarto render scribe_template.qmd --to pdf
```

This produces `scribe_template.pdf`. Open it to verify the output looks correct before submitting.

If you use **VS Code** with the Quarto extension, you can also click the **Preview** button or press `Ctrl+Shift+K` / `Cmd+Shift+K` to render.

---

## Submission

Submit the rendered **PDF file** via the course submission portal. You do not need to submit the `.qmd` source file unless specifically asked.

---

## Troubleshooting

**"Command not found: quarto"**
Quarto is not on your PATH. Restart your terminal after installation, or follow the platform-specific instructions at [quarto.org](https://quarto.org/docs/get-started/).

**LaTeX errors about missing packages**
Run `quarto install tinytex` and then try again. TinyTeX will auto-install missing packages on the first render.

**The header box is missing or misaligned**
Make sure you updated the `\lecturetitle{...}` line in the raw LaTeX block, not just the YAML fields at the top.

**Theorem environments show no output**
Theorem environments must be inside ` ```{=latex} ` raw blocks (see Step 3). Plain Markdown text between `\begin{theorem}` and `\end{theorem}` will not render.

**Math macro not working (e.g., `\E` undefined)**
Make sure you are inside a math environment: `$\E[X]$` or `$$\E[X]$$`. These macros are math-mode only.
