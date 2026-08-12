# ytoo Ruleset Optimization Design

Date: 2026-08-12

## Objective

Make `remote-config/customized/ytoo.ini` the maintained primary conversion template, merge the supplied custom routing rules, simplify overlapping policy groups, improve region matching, and remove only files proven unrelated or obsolete.

## Scope

- Update `remote-config/customized/ytoo.ini`.
- Add normalized custom rule lists under `ruleset/custom/` when different target policies require separate lists.
- Update `README.md` URLs and document the primary ytoo template.
- Preserve provider-specific templates and every file still referenced by a tracked configuration.
- Do not change subscription endpoints, node definitions, or generated client configuration files.

## Cleanup Policy

Deletion requires all of these conditions:

1. No tracked configuration or README references the file.
2. The file is duplicated, empty, or has a confirmed maintained replacement.
3. Removing it does not break a published repository URL used by a legacy template.

`filter/shadowrocket.conf` and the vendored DivineEngine lists remain. Their current upstream is unavailable, but tracked legacy templates still reference the local copies. Migration of every legacy template is separate work because it changes behavior outside the approved ytoo scope.

## Ruleset Maintenance Audit

Audit performed on 2026-08-12 using GitHub repository metadata and direct HTTP checks.

| Source | Status | Decision |
| --- | --- | --- |
| ACL4SSR/ACL4SSR | Active; pushed 2026-08-11; all 15 ytoo paths returned HTTP 200 | Keep |
| LM-Firefly/Rules | Active; pushed 2026-08-11; EHGallery path returned HTTP 200 | Keep |
| DivineEngine/Profiles | GitHub repository returns 404 | Do not add to ytoo; retain local compatibility copies only |
| MetaCubeX/meta-rules-dat | Active; pushed 2026-08-11 | Preferred GEOSITE/GEOIP source through Mihomo runtime |
| blackmatrix7/ios_rule_script | Active; pushed 2026-08-11 | Preferred list-based replacement for future legacy-template migration |
| Loyalsoldier/clash-rules | Active; pushed 2026-08-11 | Suitable general fallback |
| Aethersailor/Custom_OpenClash_Rules | Active; pushed 2026-08-11 | Suitable OpenClash-specific fallback, not required by ytoo |

No currently used ytoo URL needs replacement. New generic service coverage should prefer Mihomo `GEOSITE` and `GEOIP` entries, with maintained ACL4SSR lists as compatibility fallbacks.

## Rule Ordering

Rules are evaluated in this order:

1. Private network and explicit direct rules.
2. Domestic game download and Steam CDN direct rules.
3. User custom direct rules.
4. AI services.
5. GitHub and development services.
6. Social and messaging services.
7. Google, Apple, and Microsoft services.
8. Streaming, games, comics, and international media.
9. User-selected custom proxy rules and explicit regional routes.
10. GFW proxy rules.
11. China domains and IP ranges.
12. Final fallback.

Specific rules precede broad rules. Duplicate domains use the first intentional policy only.

## Policy Groups

The three overlapping `ChatGPT`, `Copilot`, and `AI服务` groups become one `🤖 AI服务` group. It covers OpenAI, Microsoft Copilot/Bing AI, Google Gemini/Generative Language, and their required authentication, challenge, telemetry, and realtime dependencies.

The template keeps separate groups only where users commonly need distinct routing:

- `🚀 手动选择`
- `♻️ 自动选择`
- `🤖 AI服务`
- `🚀 GitHub`
- `💬 社交媒体`
- `📢 谷歌FCM`
- `🇬 谷歌服务`
- `🍎 苹果服务`
- `Ⓜ️ 微软服务`
- `📹 YouTube`
- `🎥 Netflix`
- `🌎 国外媒体`
- `🕹️ 游戏平台`
- `🎮 Steam`
- `📖 漫画网站`
- `👤 用户规则`
- `🐟 漏网之鱼`

## Region Groups

All region groups use `url-test` with `https://www.gstatic.com/generate_204`, interval 300 seconds, tolerance 50 ms. Matching supports Chinese names, common English names, country codes, flags, and major city aliases.

Regions:

- Hong Kong
- United States
- Japan
- Singapore
- Taiwan
- South Korea
- Canada
- United Kingdom
- Australia
- France
- Germany
- Netherlands
- Turkey
- Other regions

The other-regions expression excludes every recognized region. Patterns avoid overly broad single-letter matches such as bare `US`, `UK`, or `SG` inside unrelated words where practical.

## Attachment Normalization

The attachment is parsed as rule data, not copied wholesale. Comments and disabled examples are not activated. Active rules are:

- normalized to Subconverter-compatible list syntax;
- deduplicated by rule type and value;
- assigned one intentional target based on rule priority;
- split into small policy-owned lists under `ruleset/custom/`;
- referenced from ytoo using this repository's `Kelcoin/subconverter-config@master` raw URLs.

Expected custom lists cover direct, AI, Steam, game platforms, comics, international media, user rules, and explicit regional routing. A file is created only when it contains at least one retained rule.

Conflicts are resolved as follows:

- AI service ownership wins over generic United States or user routing.
- Steam CDN direct rules win over Steam proxy rules.
- Service-specific rules win over generic regional rules.
- Explicit direct rules win only when the attachment clearly marks them direct.
- China routing remains after custom and proxy service rules so broad China lists do not shadow them.

## Validation

Verification must check:

1. Every `ruleset=` target has a matching policy group or is a built-in action.
2. Every `[]Group` reference names an existing group.
3. No duplicate custom rule has conflicting targets.
4. All external HTTP ruleset URLs respond successfully.
5. Region regexes compile and match representative node names without obvious cross-region collisions.
6. The final rule is last and China GEOIP precedes it.
7. Git diff contains no unrelated file deletion or formatting churn.

## Rollback

The change is confined to text configuration and new rule lists. Git can revert the ytoo commit without affecting subscription data or generated client state.
