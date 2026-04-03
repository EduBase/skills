<p align="center">
  <img src="https://static.edubase.net/media/brand/title/color.png" alt="EduBase logo" height="150" />
</p>

<h1 align="center">EduBase Skills</h1>

<p align="center">
  <a href="https://github.com/EduBase/skills/releases/latest"><img src="https://img.shields.io/github/v/tag/EduBase/skills?label=version" alt="Latest version" /></a>
  <a href="LICENSE"><img src="https://img.shields.io/github/license/EduBase/skills" alt="MIT License" /></a>
  <a href="https://agentskills.io"><img src="https://img.shields.io/badge/format-Agent%20Skills-blue" alt="Agent Skills format" /></a>
</p>

<p align="center">
  A collection of <a href="https://agentskills.io">Agent Skills</a> that teach AI coding agents how to work with the <a href="https://www.edubase.net">EduBase</a> e-learning platform.
</p>

---

## What are Agent Skills?

[Agent Skills](https://agentskills.io) are an open standard for giving AI agents new capabilities. A skill is a folder containing a `SKILL.md` file (instructions + metadata) along with optional templates, references, and scripts. When an agent detects a relevant task, it loads the skill automatically — no manual prompting required.

This repository packages EduBase-specific knowledge into skills that any compatible agent can use out of the box.

## Available Skills

<!-- SKILLS_TABLE_START -->

| Skill | Description | Download link|
|-------|-------------|----------|
| **[edubase-edu-writer](edubase-edu-writer/)** | Writes EduBase questions as EDU files — the single-question text format used for one-by-one upload to EduBase Quizzing. | [⬇ .skill](https://github.com/EduBase/skills/raw/main/edubase-edu-writer/edubase-edu-writer.skill) |
| **[edubase-mcp-setup](edubase-mcp-setup/)** | Guides setup and first-use of the EduBase MCP server — the integration that connects Claude to the EduBase e-learning platform. | [⬇ .skill](https://github.com/EduBase/skills/raw/main/edubase-mcp-setup/edubase-mcp-setup.skill) |
| **[edubase-question-creator](edubase-question-creator/)** | Expert EduBase question creator for the EduBase Quizzing platform. | [⬇ .skill](https://github.com/EduBase/skills/raw/main/edubase-question-creator/edubase-question-creator.skill) |

<!-- SKILLS_TABLE_END -->

## Getting Started

### Prerequisites

You need an AI coding agent that supports the [Agent Skills](https://agentskills.io) format. Compatible tools include:

- [Claude Code](https://claude.ai/code) / [Claude.ai](https://claude.ai)
- [Cursor](https://cursor.com)
- [GitHub Copilot](https://github.com/features/copilot) / [VS Code](https://code.visualstudio.com)
- [Gemini CLI](https://geminicli.com)
- [JetBrains Junie](https://junie.jetbrains.com)
- [Roo Code](https://roocode.com)
- [OpenHands](https://www.all-hands.dev)
- ...and [many more](https://agentskills.io/home)

### Download All Skills at Once

If you'd rather grab everything in one go instead of downloading skills individually:

1. Head to the [**Releases page**](https://github.com/EduBase/skills/releases/latest).
2. Under **Assets**, you'll find every `.skill` file listed individually — plus a `.zip` archive containing all of them.
3. Download the `.zip`, extract it, and you'll have every skill ready to install.

> **Tip:** The Releases page is also the easiest place to browse previous versions if you ever need an older release.

### How to Use These Skills

Pick the option that matches the tool you're using. You can use as many or as few skills as you like.

#### With Claude.ai (web or desktop app)

1. Download the `.skill` file(s) you need — either from the table above or from the [Releases page](https://github.com/EduBase/skills/releases/latest).
2. Open Claude and go to **Customize** (left sidebar) **> Skills**.

   <details>
   <summary>See where to find it</summary>

   ![Find where to upload skills](assets/claude-customize-skills-path.png)

   </details>

3. Click the **+** button, then choose **Upload a skill**.

   <details>
   <summary>See how it looks</summary>

   ![Drag and drop a .skill file into Claude](assets/claude-skill-upload.png)

   </details>

4. Drag and drop the `.skill` file into the upload area — or click to browse and select it from your computer.
5. Done! The skill is now active for all your conversations.

> **New to this?** A `.skill` file is just a small package that teaches Claude how to do something new. Think of it like installing a plugin — once uploaded, Claude automatically knows when to use it.

#### With Claude Code (CLI or IDE)

Copy the skill folders you want into one of these locations:

```bash
git clone https://github.com/EduBase/skills.git

# Option A: Add to a specific project (great for teams — everyone gets them automatically)
cp -r skills/edubase-question-creator your-project/.claude/skills/

# Option B: Add to your personal skills (available across all your projects)
cp -r skills/edubase-question-creator ~/.claude/skills/
```


#### With any other compatible agent

Copy the skill folder into the location your agent expects, or paste the contents of `SKILL.md` directly into your agent's custom instructions. See the [Agent Skills docs](https://agentskills.io) for agent-specific guidance.

### Verify it works

Once installed, ask your agent something like:

> *"Set up the EduBase MCP server"*

or

> *"Create a multiple-choice question about photosynthesis for EduBase"*

If the skill triggers and the agent follows the instructions, you're all set.

## Repository Structure

Each skill folder follows the [Agent Skills specification](https://agentskills.io/specification):

- **`SKILL.md`** — Required. Contains YAML frontmatter (`name`, `description`) and markdown instructions.
- **`references/`** — Optional. Detailed documentation loaded on demand by the agent.
- **`assets/`** — Optional. Templates and static resources.
- **`*.skill`** — Auto-generated ZIP archive of the skill folder (built by CI).

## Contributing

Contributions are welcome! Whether you're fixing a typo, improving an existing skill, or adding a new one — here's how to get started.

### Improving an existing skill

1. Fork the repository and create a feature branch.
2. Edit the `SKILL.md` or supporting files in the relevant skill folder.
3. Test your changes by loading the skill into a compatible agent and running through realistic prompts.
4. Open a pull request with a clear description of what changed and why.

### Adding a new skill

1. Fork the repository and create a feature branch.
2. Create a new folder at the repository root using **kebab-case** (e.g., `edubase-new-skill/`).
3. Add a `SKILL.md` file with the required frontmatter:

   ```yaml
   ---
   name: edubase-new-skill
   description: >
     A clear description of what this new skill does and when agents should use it.
     Include specific trigger keywords so agents can discover it reliably.
   ---
   ```

4. Write concise, actionable instructions in the markdown body. Remember:
   - Keep `SKILL.md` under **500 lines** — move detailed references to separate files.
   - Use **progressive disclosure**: put the overview in `SKILL.md`, details in `references/`.
   - Write in **third person** (the description is injected into the agent's system prompt).
   - Be specific in the `description` field — it determines whether the skill triggers at all.
5. Add optional supporting files under `references/` or `assets/` as needed.
6. Open a pull request. The CI pipeline will automatically generate the `.skill` ZIP file on merge.

### Style guidelines

- Follow the existing markdown formatting conventions (enforced by [markdownlint](https://github.com/markdownlint/markdownlint) via pre-commit hooks).
- Use consistent terminology within and across skills.
- Avoid time-sensitive information — prefer evergreen instructions.
- See the [Agent Skills best practices](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices) for detailed authoring guidance.

### CI/CD pipeline

You don't need to build `.skill` files manually. When changes to skill content are pushed to `main`:

1. **`generate-skills.sh`** packages each skill folder into a deterministic `.skill` ZIP.
2. **`update-readme-skills-table.sh`** regenerates the Available Skills table from `SKILL.md` frontmatter.
3. **`commit-changes.sh`** commits the updated archives and creates a new version tag.
4. **GitHub Actions** publishes a release with the `.skill` files attached.

## License

This project is licensed under the [MIT License](LICENSE).

---

<p align="center">
  Built for the <a href="https://www.edubase.net">EduBase</a> e-learning platform
</p>
