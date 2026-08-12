# ytoo Ruleset Optimization Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Reduce repository to a maintained ytoo conversion template, normalized custom rules, and documentation.

**Architecture:** `ytoo.ini` owns policy order and groups. Focused text rulesets under `ruleset/custom/` own attachment-derived entries. A PowerShell validator checks cross-references, conflicts, ordering, region coverage, and repository scope.

**Tech Stack:** Subconverter INI syntax, Clash classical rule syntax, PowerShell validation, Git.

## Global Constraints

- Keep ACL4SSR and LM-Firefly URLs that passed maintenance and HTTP checks.
- Prefer built-in `GEOSITE`/`GEOIP` for broad maintained coverage.
- Merge ChatGPT, Copilot, and Google AI into `🤖 AI服务`.
- Keep only the ytoo usage chain; other templates may be deleted.
- Preserve explicit attachment intent while resolving duplicates by first-match policy.

---

### Task 1: Configuration Contract

**Files:**
- Create: `scripts/validate-ytoo.ps1`
- Test: `remote-config/customized/ytoo.ini`

**Interfaces:**
- Consumes: ytoo INI and `ruleset/custom/*.list`.
- Produces: exit code 0 only when group references, ordering, custom URLs, region groups, and repository scope are valid.

- [ ] Write validation for one AI group, required regions including Australia, valid group references, unique custom rules, final ordering, HTTPS health-check URL, and allowed repository paths.
- [ ] Run `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/validate-ytoo.ps1` and confirm failure against old template.

### Task 2: Normalize Attachment Rules

**Files:**
- Create: `ruleset/custom/*.list`

**Interfaces:**
- Consumes: active rules from supplied attachment.
- Produces: policy-owned classical rule lists without target suffixes.

- [ ] Extract active rules, remove comments, and strip target policy names.
- [ ] Deduplicate exact rule keys and resolve cross-list conflicts using approved priority.
- [ ] Run validator and confirm remaining failures concern ytoo references or repository scope, not list conflicts.

### Task 3: Rebuild ytoo

**Files:**
- Modify: `remote-config/customized/ytoo.ini`

**Interfaces:**
- Consumes: maintained external rules and `ruleset/custom/*.list` raw URLs.
- Produces: all policy groups and ordered rules for Subconverter.

- [ ] Replace old rules with private/direct, custom, service, China, and final sections in approved order.
- [ ] Add consolidated `🤖 AI服务` group and remove separate ChatGPT/Copilot groups.
- [ ] Add url-test groups for HK, US, JP, SG, TW, KR, CA, UK, AU, FR, DE, NL, TR and other regions.
- [ ] Run validator and fix all ytoo contract failures.

### Task 4: Remove Non-ytoo Files and Document Usage

**Files:**
- Modify: `README.md`
- Delete: `filter/`, `tpls/`, non-ytoo `remote-config/` files, and old `ruleset/` files outside `ruleset/custom/`.

**Interfaces:**
- Consumes: completed ytoo usage chain.
- Produces: minimal remote configuration repository.

- [ ] Update README with correct repository URLs, ytoo endpoint, retained sources, and validation command.
- [ ] Enumerate exact deletion targets and remove only paths outside ytoo chain.
- [ ] Run validator, `git diff --check`, and inspect `git status --short`.

### Task 5: Final Verification

**Files:**
- Verify all retained files.

**Interfaces:**
- Consumes: final repository.
- Produces: evidence that config structure and remote sources are usable.

- [ ] Run validator.
- [ ] Check every retained external URL with parallel HTTP HEAD requests.
- [ ] Run `git diff --check` and review deletion/addition summary.
- [ ] Record results in progress log.
