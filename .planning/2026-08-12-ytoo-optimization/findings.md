# Findings

- Worktree clean at commit `7ec9ebb` on `master`.
- Top level contains `README.md`, `filter/`, `remote-config/`, `ruleset/`, and `tpls/`.
- No `AGENTS.md` found.
- Attachment contains roughly 900 lines of Clash rules and comments.
- Attachment has overlapping categories and duplicate/conflicting destinations, including Copilot/OpenAI domains and domains repeated across region or direct groups.
- User approved the conservative cleanup scope and recommended ytoo-focused design.
- ACL4SSR/ACL4SSR and LM-Firefly/Rules are active and had pushes on 2026-08-11.
- DivineEngine/Profiles returns GitHub 404 and should be treated as an unavailable upstream; its vendored files remain only for compatibility with legacy templates until those references are migrated.
- Active replacement candidates checked: MetaCubeX/meta-rules-dat, blackmatrix7/ios_rule_script, Loyalsoldier/clash-rules, and Aethersailor/Custom_OpenClash_Rules all had pushes on 2026-08-11.
- `npx skills find clash subconverter` failed because npm could not write its cache; no specialized skill was installed.
- All 16 external ruleset paths currently referenced by ytoo returned HTTP 200 on 2026-08-12.
- Existing ytoo sources need no immediate replacement; prefer MetaCubeX runtime GEOSITE/GEOIP and ACL4SSR compatibility lists for new coverage.
