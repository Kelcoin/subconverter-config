$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$configPath = Join-Path $root 'remote-config/customized/ytoo.ini'
$errors = [System.Collections.Generic.List[string]]::new()

function ConvertFrom-UnicodeEscape([string]$value) {
    return [regex]::Replace($value, '\\u([0-9a-fA-F]{4})', {
        param($match)
        return [char]([Convert]::ToInt32($match.Groups[1].Value, 16))
    })
}

if (-not (Test-Path -LiteralPath $configPath)) {
    throw "Missing ytoo config: $configPath"
}

$lines = Get-Content -LiteralPath $configPath -Encoding UTF8
$groups = @($lines | Where-Object { $_ -match '^custom_proxy_group=([^`]+)`' } | ForEach-Object { $Matches[1] })
$targets = @($lines | Where-Object { $_ -match '^ruleset=([^,]+),' } | ForEach-Object { $Matches[1] })
$builtins = @('DIRECT', 'REJECT')

$ruleLines = @($lines | Where-Object { $_ -match '^ruleset=' })
$customRuleLines = @($ruleLines | Where-Object { $_ -match 'Kelcoin/subconverter-config/master/ruleset/custom/' })
if ($customRuleLines.Count -eq 0) {
    $errors.Add('No attachment-derived custom rulesets are referenced')
} else {
    $leadingCustomCount = 0
    foreach ($line in $ruleLines) {
        if ($line -match 'Kelcoin/subconverter-config/master/ruleset/custom/') {
            $leadingCustomCount++
        } else {
            break
        }
    }
    if ($leadingCustomCount -ne $customRuleLines.Count) {
        $errors.Add('All attachment-derived custom rulesets must precede every external or built-in ruleset')
    }
}

foreach ($target in $targets | Sort-Object -Unique) {
    if ($target -notin $builtins -and $target -notin $groups) {
        $errors.Add("Ruleset target has no policy group: $target")
    }
}

foreach ($line in $lines | Where-Object { $_ -like 'custom_proxy_group=*' }) {
    foreach ($match in [regex]::Matches($line, '\[\]([^`]+)')) {
        $reference = $match.Groups[1].Value
        if ($reference -notin $builtins -and $reference -notin $groups) {
            $errors.Add("Policy group reference is missing: $reference")
        }
    }
}

$aiGroup = ConvertFrom-UnicodeEscape '\uD83E\uDD16 AI\u670D\u52A1'
$chatGptGroup = ConvertFrom-UnicodeEscape '\uD83E\uDD16 ChatGPT'
$copilotGroup = ConvertFrom-UnicodeEscape '\uD83E\uDD16 Copilot'
if (($groups | Where-Object { $_ -eq $aiGroup }).Count -ne 1) {
    $errors.Add('Expected exactly one consolidated AI policy group')
}
if ($groups -contains $chatGptGroup -or $groups -contains $copilotGroup) {
    $errors.Add('ChatGPT and Copilot must be merged into AI服务')
}

$requiredRegions = @(
    '\uD83C\uDDED\uD83C\uDDF0 \u9999\u6E2F\u8282\u70B9',
    '\uD83C\uDDFA\uD83C\uDDF8 \u7F8E\u56FD\u8282\u70B9',
    '\uD83C\uDDEF\uD83C\uDDF5 \u65E5\u672C\u8282\u70B9',
    '\uD83C\uDDF8\uD83C\uDDEC \u65B0\u52A0\u5761\u8282\u70B9',
    '\uD83C\uDDF9\uD83C\uDDFC \u53F0\u6E7E\u8282\u70B9',
    '\uD83C\uDDF0\uD83C\uDDF7 \u97E9\u56FD\u8282\u70B9',
    '\uD83C\uDDE8\uD83C\uDDE6 \u52A0\u62FF\u5927\u8282\u70B9',
    '\uD83C\uDDEC\uD83C\uDDE7 \u82F1\u56FD\u8282\u70B9',
    '\uD83C\uDDE6\uD83C\uDDFA \u6FB3\u5927\u5229\u4E9A\u8282\u70B9',
    '\uD83C\uDDEB\uD83C\uDDF7 \u6CD5\u56FD\u8282\u70B9',
    '\uD83C\uDDE9\uD83C\uDDEA \u5FB7\u56FD\u8282\u70B9',
    '\uD83C\uDDF3\uD83C\uDDF1 \u8377\u5170\u8282\u70B9',
    '\uD83C\uDDF9\uD83C\uDDF7 \u571F\u8033\u5176\u8282\u70B9',
    '\uD83C\uDF10 \u5176\u4ED6\u5730\u533A'
) | ForEach-Object { ConvertFrom-UnicodeEscape $_ }
foreach ($region in $requiredRegions) {
    if ($groups -notcontains $region) { $errors.Add("Missing region group: $region") }
}

if ($lines -match 'http://www\.gstatic\.com/generate_204') {
    $errors.Add('Health-check URL must use HTTPS')
}

$finalIndex = [array]::FindLastIndex([string[]]$lines, [Predicate[string]]{ param($line) $line -match '^ruleset=.*\[\](FINAL|MATCH)$' })
$lastRuleIndex = [array]::FindLastIndex([string[]]$lines, [Predicate[string]]{ param($line) $line -match '^ruleset=' })
if ($finalIndex -lt 0 -or $finalIndex -ne $lastRuleIndex) {
    $errors.Add('FINAL ruleset must be the last ruleset')
}

$customDir = Join-Path $root 'ruleset/custom'
if (-not (Test-Path -LiteralPath $customDir)) {
    $errors.Add('Missing ruleset/custom directory')
} else {
    $customFiles = @(Get-ChildItem -LiteralPath $customDir -Filter '*.list')
    if ($customRuleLines.Count -ne $customFiles.Count) {
        $errors.Add("Expected one leading ruleset reference for each custom list: found $($customRuleLines.Count) references and $($customFiles.Count) files")
    }
    $seen = @{}
    $customFiles | ForEach-Object {
        $file = $_
        Get-Content -LiteralPath $file.FullName -Encoding UTF8 | Where-Object { $_ -and -not $_.StartsWith('#') } | ForEach-Object {
            $parts = $_ -split ','
            if ($parts.Count -lt 2) {
                $errors.Add("Invalid rule in $($file.Name): $_")
            } else {
                $key = "$($parts[0]),$($parts[1])".ToLowerInvariant()
                if ($seen.ContainsKey($key)) {
                    $errors.Add("Duplicate custom rule $key in $($seen[$key]) and $($file.Name)")
                } else {
                    $seen[$key] = $file.Name
                }
            }
        }
    }
}

$allowedTopLevel = @('.git','.planning','docs','remote-config','ruleset','scripts','README.md')
Get-ChildItem -LiteralPath $root -Force | Where-Object { $_.Name -notin $allowedTopLevel } | ForEach-Object {
    $errors.Add("Unexpected top-level path outside ytoo chain: $($_.Name)")
}

if ($errors.Count -gt 0) {
    $errors | ForEach-Object { Write-Error $_ -ErrorAction Continue }
    exit 1
}

Write-Host "ytoo validation passed: $($groups.Count) groups, $($targets.Count) rulesets"
