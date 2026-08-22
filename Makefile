CLAUDE_DIR   ?= $(HOME)/.claude
OPENCODE_DIR ?= $(HOME)/.config/opencode
AGENTS_DIR   ?= $(HOME)/.agents
ROOT         := $(CURDIR)

.PHONY: install
install: install-skills install-statusline install-settings install-claude-json install-opencode-json install-plugins
	@echo "done — restart Claude Code to pick up settings changes"

.PHONY: install-skills
install-skills:
	@for target in "$(CLAUDE_DIR)/skills" "$(AGENTS_DIR)/skills"; do \
		mkdir -p "$$target"; \
		for dir in "$(ROOT)"/skills/*/; do \
			name=$$(basename "$$dir"); \
			ln -sfn "$(ROOT)/skills/$$name" "$$target/$$name"; \
			echo "skill      $$name -> $$target/$$name"; \
		done; \
	done

.PHONY: install-statusline
install-statusline:
	@mkdir -p "$(CLAUDE_DIR)"
	@ln -sf "$(ROOT)/.claude/statusline-command.sh" "$(CLAUDE_DIR)/statusline-command.sh"
	@echo "statusline -> $(CLAUDE_DIR)/statusline-command.sh"

# Renders .claude/config/settings.json (placeholders -> absolute paths), then deep-merges
# it into ~/.claude/settings.json. See scripts/install-settings.sh.
.PHONY: install-settings
install-settings:
	@ROOT="$(ROOT)" CLAUDE_DIR="$(CLAUDE_DIR)" "$(ROOT)/scripts/install-settings.sh"

# Renders .claude/config/claude.json (placeholders -> absolute paths), then deep-merges
# it into ~/.claude.json (Claude Code's global config). See scripts/install-claude-json.sh.
.PHONY: install-claude-json
install-claude-json:
	@ROOT="$(ROOT)" "$(ROOT)/scripts/install-claude-json.sh"

# Renders .opencode/config/opencode.jsonc (placeholders -> absolute paths), then
# deep-merges it into ~/.config/opencode/opencode.jsonc (OpenCode's global config).
# See scripts/install-opencode-json.sh.
.PHONY: install-opencode-json
install-opencode-json:
	@ROOT="$(ROOT)" OPENCODE_DIR="$(OPENCODE_DIR)" "$(ROOT)/scripts/install-opencode-json.sh"

# Registers the repo marketplace and installs every plugin it declares.
# See scripts/install-plugins.sh.
.PHONY: install-plugins
install-plugins:
	@ROOT="$(ROOT)" "$(ROOT)/scripts/install-plugins.sh"

# Injects AGENTS.md at the top of ~/.claude/CLAUDE.md, wrapped in managed markers,
# and configures a global git ignore file (both idempotent). Deliberately excluded
# from `install` — run it explicitly.
# See scripts/install-persona.sh and scripts/setup-gitignore-global.sh.
.PHONY: install-persona
install-persona:
	@ROOT="$(ROOT)" CLAUDE_DIR="$(CLAUDE_DIR)" "$(ROOT)/scripts/install-persona.sh"
	@ROOT="$(ROOT)" "$(ROOT)/scripts/setup-gitignore-global.sh"
