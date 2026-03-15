```
 ██████╗ ██████╗ ███████╗███╗   ██╗ ██████╗ ██████╗ ██████╗ ███████╗
██╔═══██╗██╔══██╗██╔════╝████╗  ██║██╔════╝██╔═══██╗██╔══██╗██╔════╝
██║   ██║██████╔╝█████╗  ██╔██╗ ██║██║     ██║   ██║██║  ██║█████╗
██║   ██║██╔═══╝ ██╔══╝  ██║╚██╗██║██║     ██║   ██║██║  ██║██╔══╝
╚██████╔╝██║     ███████╗██║ ╚████║╚██████╗╚██████╔╝██████╔╝███████╗
 ╚═════╝ ╚═╝     ╚══════╝╚═╝  ╚═══╝ ╚═════╝ ╚═════╝ ╚═════╝ ╚══════╝

    ██████╗ ██████╗ ███╗   ██╗███████╗██╗ ██████╗
   ██╔════╝██╔═══██╗████╗  ██║██╔════╝██║██╔════╝
   ██║     ██║   ██║██╔██╗ ██║█████╗  ██║██║  ███╗
   ██║     ██║   ██║██║╚██╗██║██╔══╝  ██║██║   ██║
   ╚██████╗╚██████╔╝██║ ╚████║██║     ██║╚██████╔╝
    ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝     ╚═╝ ╚═════╝
```

> _"These are intelligent and structured group dynamics that emerge not from a leader, but from the local interactions of the elements themselves."_
> — Daniel Shiffman, _The Nature of Code_

**An AI-driven multi-agent system with dynamic scaling.**

You describe what you want. The primary agent analyzes the task, decides the execution strategy, and orchestrates subagents efficiently. No hardcoded rules — the AI decides when to swarm and how many workers to spawn.

Built on [`joelhooks/swarmtools`](https://github.com/joelhooks/swarmtools) - multi-agent orchestration with outcome-based learning.

> [!IMPORTANT]
> **This is an OpenCode config, not a standalone tool.** Everything runs inside OpenCode. The CLIs (`swarm`, `cass`) are backends that agents call - not meant for direct human use.

---

## Quick Start

### 0. Install OpenCode

Install OpenCode via the official install script or the Homebrew tap.

- Install script: `curl -fsSL https://opencode.ai/install | bash`
- Homebrew: `brew install anomalyco/tap/opencode`

### 1. Clone & Install

```bash
git clone https://github.com/joelhooks/opencode-config ~/.config/opencode
cd ~/.config/opencode && bun install
```

### 2. Install CLI Tools

> [!NOTE]
> These CLIs are backends that OpenCode agents call. You install them, but the agents use them.

```bash
# Swarm orchestration (required) - agents call this for coordination
npm install -g opencode-swarm-plugin
swarm --version  # 0.30.0+

# Ollama for embeddings (required for semantic features)
brew install ollama  # or: curl -fsSL https://ollama.com/install.sh | sh
ollama serve
ollama pull nomic-embed-text

# Cross-agent session search (optional but recommended)
npm install -g cass-search
cass index
cass --version  # 0.1.35+
```

### 3. Verify

```bash
swarm doctor
```

### 4. Run

Start OpenCode and use `/build` or `/plan` mode:

```bash
# Build mode - AI-driven orchestrator with auto-scaling
/build

# Plan mode - AI-driven task analysis
/plan
```

The agent will analyze your task and decide the best execution strategy.

---

## AI-Driven Dynamic Scaling

```
┌─────────────────────────────────────────────────────────────────────┐
│                     PRIMARY AGENT (orchestrator)                      │
│                   (YOU - the AI - decide the strategy)               │
│                                                                       │
│  ┌───────────────────────────────────────────────────────────────┐ │
│  │  Task Analysis Engine                                            │ │
│  │  • Analyzes: files, complexity, dependencies, risk             │ │
│  │  • Decides: sequential | small-swarm | full-swarm              │ │
│  │  • Selects: appropriate subagents (0, 1-2, or N)              │ │
│  └───────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────┘
                                │
        ┌───────────────────────┼───────────────────────┐
        ▼                       ▼                       ▼
  ┌──────────┐           ┌──────────┐           ┌──────────┐
  │subagent 1│           │subagent 2│           │subagent N│
  │  (work)  │           │  (work)  │           │  (work)  │
  └──────────┘           └──────────┘           └──────────┘
        │                       │                       │
        └───────────────────────┼───────────────────────┘
                                ▼
                    ┌─────────────────────┐
                    │   Primary Agent      │
                    │   (coordinates)      │
                    └─────────────────────┘
```

### Execution Strategies

| Strategy | When to Use | Subagents |
|----------|-------------|-----------|
| **Sequential** | Simple tasks (<2 files, single change) | 0 - execute directly |
| **Small-Swarm** | Moderate tasks (2-5 files) | 1-2 subagents in parallel |
| **Full-Swarm** | Complex tasks (5+ files, architectural) | N subagents with orchestration |

**The AI decides.** No hardcoded thresholds. Trust the agent's judgment.

---

## Primary Agents

### Build Agent (`build`)

The orchestrator. Coordinates subagent work, manages task decomposition.

**Capabilities:**
- AI-driven complexity analysis
- Dynamic subagent spawning (0 → 1-2 → N)
- Full swarm orchestration via `swarm_*` tools
- Quality gates (lint, tests, review)

**Workflow:**
1. Analyze task scope
2. Decide execution strategy
3. Spawn appropriate subagents
4. Coordinate work
5. Verify results

### Plan Agent (`plan`)

The analyzer. Creates structured task breakdowns with workflow recommendations.

**Capabilities:**
- AI-driven task analysis
- Project domain discovery
- Complexity assessment
- Structured breakdowns with dependencies
- Workflow recommendations (sequential/small-swarm/full-swarm)

**Workflow:**
1. Discover project domain
2. Analyze task requirements
3. Recommend execution strategy
4. Create structured breakdown
5. Delegate to build agent

---

## Subagents

Workers spawned by the primary agent. Never spawn primary agents as workers.

| Subagent | Purpose | Use When |
|----------|---------|----------|
| **builder** | Implementation, TDD | Writing/modifying code |
| **tester** | Unit, integration, e2e | Any code change needs tests |
| **debugger** | Troubleshooting | Bug fixes, errors |
| **researcher** | Tech research | Need domain knowledge |
| **architect** | Design decisions | Architectural changes |
| **reviewer** | Code review | Before completion |
| **migrator** | Code migrations | Refactoring, upgrades |
| **integrator** | API integrations | External service work |
| **perf-engineer** | Optimization | Performance-critical |
| **security-devops** | Security, CI/CD | Infrastructure changes |
| **issue-tracker** | Bug triage | Finding issues to file |

---

## Swarm Tools

| Tool | Purpose |
|------|---------|
| `swarm_decompose` | Break complex task into subtasks |
| `swarm_spawn_subtask` | Spawn subagent for specific subtask |
| `swarm_progress` | Track worker progress (25/50/75/100%) |
| `swarm_status` | Get current swarm status |
| `swarm_complete` | Mark subtask complete with verification |
| `swarm_broadcast` | Send context update to all workers |
| `swarm_record_outcome` | Record task outcome for learning |

---

## The Learning System

```
┌─────────────────────────────────────────────────────────────────┐
│                     LEARNING PIPELINE                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐         │
│  │   CASS      │───▶│  Decompose  │───▶│   Execute   │         │
│  │  (history)  │    │  (strategy) │    │  (workers)  │         │
│  └─────────────┘    └─────────────┘    └─────────────┘         │
│         │                                     │                 │
│         │                                     ▼                 │
│         │                            ┌─────────────┐           │
│         │                            │   Record    │           │
│         │                            │  Outcome    │           │
│         │                            └─────────────┘           │
│         │                                     │                 │
│         ▼                                     ▼                 │
│  ┌─────────────────────────────────────────────────┐           │
│  │              PATTERN MATURITY                    │           │
│  │  candidate → established → proven → deprecated   │           │
│  └─────────────────────────────────────────────────┘           │
│                                                                 │
│  • Confidence decay (90-day half-life)                         │
│  • Anti-pattern inversion (>60% failure → AVOID)               │
│  • Implicit feedback (fast+success vs slow+errors)             │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Every task execution feeds the learning system:**

- **Fast + success** → pattern gets promoted
- **Slow + retries + errors** → pattern gets flagged
- **>60% failure rate** → auto-inverted to anti-pattern
- **90-day half-life** → confidence decays unless revalidated

---

## Configuration & Permissions

OpenCode merges configuration from multiple sources with defined precedence.

Permissions support `allow`, `ask`, and `deny` rules. When multiple rules match, the last match wins.

### Agent Configuration

Agents are configured in `opencode.jsonc`:

```jsonc
"agent": {
  "build": {
    "mode": "primary",
    "prompt": "{file:./agents/build.md}",
    "tools": { "write": true, "edit": true, "bash": true, ... },
    "permission": { "swarm_*": "allow", "hive_*": "allow", ... }
  },
  "plan": {
    "mode": "primary", 
    "prompt": "{file:./agents/plan.md}",
    "tools": { "write": false, "edit": false, "bash": false, ... }
  }
}
```

---

## Version Reference

| Tool   | Version | Install Command                  |
| ------ | ------- | -------------------------------- |
| swarm  | 0.30.0  | `npm i -g opencode-swarm-plugin` |
| cass   | 0.1.35  | `npm i -g cass-search`           |
| ollama | 0.13.1  | `brew install ollama`            |

**Embedding model:** `nomic-embed-text` (required for hivemind)

---

## Custom Tools

### UBS - Ultimate Bug Scanner

Multi-language bug detection (JS/TS, Python, C++, Rust, Go, Java, Ruby):

```bash
ubs_scan(staged=true)  # Before commit
ubs_scan(path="src/")  # After AI generates code
```

### CASS - Cross-Agent Session Search

```bash
cass_search(query="authentication error", limit=5)
```

### Hivemind (Semantic Memory)

```bash
hivemind_store(information="OAuth tokens need 5min buffer", tags="auth,tokens")
hivemind_find(query="token refresh", limit=5)
```

---

## MCP Servers

| Server              | Purpose                                                |
| ------------------- | ------------------------------------------------------ |
| **context7**       | Library documentation lookup (npm, PyPI, Maven)       |
| **fetch**          | Web fetching with markdown conversion                  |

---

## Knowledge Files

Domain-specific knowledge for:

| Domain | Files |
|--------|-------|
| `mobile` | iOS, Android, Flutter, React Native |
| `embedded` | Bare-metal, RTOS, firmware |
| `robotics` | ROS, ROS2, sensor/actuator |
| `backend` | API services, microservices |

Load via `@knowledge/{domain}/...` references.

---

## Directory Structure

```
┌─────────────────────────────────────────────────────────────────┐
│                        ~/.config/opencode                        │
├─────────────────────────────────────────────────────────────────┤
│  agent/             Primary agents (build.md, plan.md)           │
│  agents/subagents/  Specialized subagents                       │
│  knowledge/         Domain-specific context files               │
│  command/           Slash commands                              │
│  tool/              Custom MCP tools                            │
│  plugin/            Swarm orchestration                         │
│  opencode.jsonc     Main configuration                          │
│  AGENTS.md          Workflow instructions                        │
└─────────────────────────────────────────────────────────────────┘
```

---

## Credits

- **[joelhooks/swarmtools](https://github.com/joelhooks/swarmtools)** - The swarm orchestration core
- **[nexxeln/opencode-config](https://github.com/nexxeln/opencode-config)** - `/rmslop`, notify plugin
- **[OpenCode](https://opencode.ai)** - The foundation

---

## License

MIT

---

> _"One person's pattern can be another person's primitive building block."_
> — Eric Evans, _Domain-Driven Design_
