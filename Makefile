CLAUDE_DIR ?= $(HOME)/.claude
ROOT       := $(CURDIR)

.PHONY: install install-skills install-commands install-statusline install-settings install-plugins

install: install-skills install-commands install-statusline install-settings install-plugins
	@echo "done — restart Claude Code to pick up settings changes"

install-skills:
	@mkdir -p "$(CLAUDE_DIR)/skills"
	@for dir in "$(ROOT)"/skills/*/; do \
		name=$$(basename "$$dir"); \
		ln -sfn "$(ROOT)/skills/$$name" "$(CLAUDE_DIR)/skills/$$name"; \
		echo "skill      $$name -> $(CLAUDE_DIR)/skills/$$name"; \
	done

install-commands:
	@mkdir -p "$(CLAUDE_DIR)/commands"
	@for file in "$(ROOT)"/.claude/commands/*.md; do \
		name=$$(basename "$$file"); \
		ln -sf "$$file" "$(CLAUDE_DIR)/commands/$$name"; \
		echo "command    $$name -> $(CLAUDE_DIR)/commands/$$name"; \
	done

install-statusline:
	@mkdir -p "$(CLAUDE_DIR)"
	@ln -sf "$(ROOT)/.claude/statusline-command.sh" "$(CLAUDE_DIR)/statusline-command.sh"
	@echo "statusline -> $(CLAUDE_DIR)/statusline-command.sh"

# Renders config/settings.json (placeholders -> absolute paths), then deep-merges
# it into ~/.claude/settings.json. Repo values win on conflict; permissions.allow
# is a union so locally added entries survive. A .bak is written before merging.
install-settings:
	@command -v jq >/dev/null 2>&1 || { echo "error: jq is required (brew install jq)"; exit 1; }
	@mkdir -p "$(CLAUDE_DIR)"
	@rendered=$$(mktemp) && merged=$$(mktemp); \
	sed -e 's|{{DOTAGENTS}}|$(ROOT)|g' -e 's|{{HOME}}|$(HOME)|g' "$(ROOT)/config/settings.json" > "$$rendered"; \
	if [ -f "$(CLAUDE_DIR)/settings.json" ]; then \
		jq -e 'type == "object"' "$(CLAUDE_DIR)/settings.json" >/dev/null 2>&1 \
			|| { echo "error: $(CLAUDE_DIR)/settings.json is not a valid JSON object — fix or remove it first"; rm -f "$$rendered" "$$merged"; exit 1; }; \
		cp "$(CLAUDE_DIR)/settings.json" "$(CLAUDE_DIR)/settings.json.bak"; \
		jq -s '((.[0].permissions.allow // []) + (.[1].permissions.allow // []) | unique) as $$allow \
			| .[0] * .[1] | .permissions.allow = $$allow' \
			"$(CLAUDE_DIR)/settings.json" "$$rendered" > "$$merged" \
			|| { echo "error: merge failed — $(CLAUDE_DIR)/settings.json left untouched"; rm -f "$$rendered" "$$merged"; exit 1; }; \
		mv "$$merged" "$(CLAUDE_DIR)/settings.json"; \
		echo "settings   merged into $(CLAUDE_DIR)/settings.json (backup: settings.json.bak)"; \
	else \
		mv "$$rendered" "$(CLAUDE_DIR)/settings.json"; \
		echo "settings   created $(CLAUDE_DIR)/settings.json"; \
	fi; \
	rm -f "$$rendered" "$$merged"

# Registers the repo marketplace and installs every plugin it declares, via the
# claude CLI (both commands are no-ops when already done). Without the CLI this
# is skipped — the settings merge already declares extraKnownMarketplaces +
# enabledPlugins, so Claude Code auto-installs them on the next launch.
install-plugins:
	@command -v claude >/dev/null 2>&1 \
		|| { echo "plugins    skipped: claude CLI not found (auto-installs from settings on next launch)"; exit 0; }
	@command -v jq >/dev/null 2>&1 || { echo "error: jq is required (brew install jq)"; exit 1; }
	@marketplace=$$(jq -r '.name' "$(ROOT)/.claude/plugins/.claude-plugin/marketplace.json") && \
	claude plugin marketplace add "$(ROOT)/.claude/plugins" && \
	for plugin in $$(jq -r '.plugins[].name' "$(ROOT)/.claude/plugins/.claude-plugin/marketplace.json"); do \
		claude plugin install --scope user "$$plugin@$$marketplace" || exit 1; \
	done
