# dLearning Orchestrator — clone the real repos as read-only reference siblings.
# Real code is edited in the real repos; the orchestrator only points at them.

GH_ORG   ?= datnm555
GH_BASE  ?= https://github.com/$(GH_ORG)
REPOS    := dlearning-be dlearning-web

.PHONY: help clone-all pull-all status branches list clean

help:
	@echo "dLearning orchestrator targets:"
	@echo "  make clone-all   Clone all reference repos (idempotent — skips existing)"
	@echo "  make pull-all    git pull each reference repo"
	@echo "  make status      git status --short for each repo"
	@echo "  make branches    current branch of each repo"
	@echo "  make list        list managed repos"
	@echo "  make clean       remove reference clones (does NOT touch real repos elsewhere)"

clone-all:
	@for r in $(REPOS); do \
		if [ -d "$$r/.git" ]; then \
			echo "✓ $$r already cloned — skipping"; \
		else \
			echo "→ cloning $$r"; git clone $(GH_BASE)/$$r.git $$r; \
		fi; \
	done

pull-all:
	@for r in $(REPOS); do \
		if [ -d "$$r/.git" ]; then echo "→ pulling $$r"; git -C $$r pull --ff-only; \
		else echo "✗ $$r not cloned (run: make clone-all)"; fi; \
	done

status:
	@for r in $(REPOS); do \
		if [ -d "$$r/.git" ]; then echo "===== $$r ====="; git -C $$r status --short --branch; \
		else echo "✗ $$r not cloned"; fi; \
	done

branches:
	@for r in $(REPOS); do \
		if [ -d "$$r/.git" ]; then printf "%-16s %s\n" "$$r" "$$(git -C $$r rev-parse --abbrev-ref HEAD)"; \
		else printf "%-16s %s\n" "$$r" "(not cloned)"; fi; \
	done

list:
	@for r in $(REPOS); do echo "$$r  ->  $(GH_BASE)/$$r.git"; done

clean:
	@for r in $(REPOS); do \
		if [ -d "$$r/.git" ]; then echo "→ removing reference clone $$r"; rm -rf "$$r"; fi; \
	done
