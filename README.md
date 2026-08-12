# subconverter-config

Repository maintains one primary Subconverter remote template: `ytoo.ini`.

## ytoo

```text
https://cdn.jsdelivr.net/gh/Kelcoin/subconverter-config@master/remote-config/customized/ytoo.ini
```

Raw GitHub URL:

```text
https://raw.githubusercontent.com/Kelcoin/subconverter-config/master/remote-config/customized/ytoo.ini
```

The template merges custom AI, Steam, games, media, comic, user, direct, and regional rules. AI services (ChatGPT, Copilot, Gemini and related dependencies) use one `AI服务` policy group. Regional groups include Hong Kong, United States, Japan, Singapore, Taiwan, South Korea, Canada, United Kingdom, Australia, France, Germany, Netherlands, and Turkey.

## Rule sources

- ACL4SSR lists: actively maintained and HTTP-checked on 2026-08-12.
- LM-Firefly EHGallery list: actively maintained and HTTP-checked on 2026-08-12.
- Local custom rules: `ruleset/custom/`, generated from the supplied custom rule attachment.

DivineEngine is not used by the ytoo template. The repository was reduced to the ytoo usage chain; other provider templates and legacy rule copies were removed.

## Validation

Run from repository root:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/validate-ytoo.ps1
```
