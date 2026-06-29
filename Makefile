CLAUDE_DIR ?= $(HOME)/.claude
ROOT       := $(CURDIR)

.PHONY: install
install: install-skills install-commands install-statusline install-settings install-claude-json install-plugins
	@echo "done — restart Claude Code to pick up settings changes"

.PHONY: install-skills
install-skills:
	@mkdir -p "$(CLAUDE_DIR)/skills"
	@for dir in "$(ROOT)"/skills/*/; do \
		name=$$(basename "$$dir"); \
		ln -sfn "$(ROOT)/skills/$$name" "$(CLAUDE_DIR)/skills/$$name"; \
		echo "skill      $$name -> $(CLAUDE_DIR)/skills/$$name"; \
	done

.PHONY: install-commands
install-commands:
	@mkdir -p "$(CLAUDE_DIR)/commands"
	@for file in "$(ROOT)"/.claude/commands/*.md; do \
		name=$$(basename "$$file"); \
		ln -sf "$$file" "$(CLAUDE_DIR)/commands/$$name"; \
		echo "command    $$name -> $(CLAUDE_DIR)/commands/$$name"; \
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
