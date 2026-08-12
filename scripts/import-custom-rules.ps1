param(
    [Parameter(Mandatory = $true)]
    [string]$InputPath
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$outputDir = Join-Path $root 'ruleset/custom'

function U([string]$value) {
    return [regex]::Replace($value, '\\u([0-9a-fA-F]{4})', {
        param($match)
        [char]([Convert]::ToInt32($match.Groups[1].Value, 16))
    })
}

$targetMap = @{
    'DIRECT' = @{ File = 'direct.list'; Rank = 0 }
    (U '\uD83E\uDD16 Copilot') = @{ File = 'ai.list'; Rank = 1 }
    (U '\uD83E\uDD16 AI\u670D\u52A1') = @{ File = 'ai.list'; Rank = 1 }
    (U '\uD83C\uDFAE Steam') = @{ File = 'steam.list'; Rank = 2 }
    (U '\uD83D\uDD79\uFE0F \u6E38\u620F\u5E73\u53F0') = @{ File = 'game.list'; Rank = 2 }
    (U '\uD83D\uDCD6 \u6F2B\u753B\u7F51\u7AD9') = @{ File = 'comic.list'; Rank = 2 }
    (U '\uD83C\uDF0E \u56FD\u5916\u5A92\u4F53') = @{ File = 'media.list'; Rank = 2 }
    (U '\uD83D\uDC64 \u7528\u6237\u89C4\u5219') = @{ File = 'user.list'; Rank = 3 }
    (U '\uD83D\uDE80 \u624B\u52A8\u9009\u62E9') = @{ File = 'user.list'; Rank = 3 }
    (U '\uD83C\uDDED\uD83C\uDDF0 \u9999\u6E2F\u8282\u70B9') = @{ File = 'region-hk.list'; Rank = 4 }
    (U '\uD83C\uDDF8\uD83C\uDDEC \u65B0\u52A0\u5761\u8282\u70B9') = @{ File = 'region-sg.list'; Rank = 4 }
    (U '\uD83C\uDDEF\uD83C\uDDF5 \u65E5\u672C\u8282\u70B9') = @{ File = 'region-jp.list'; Rank = 4 }
    (U '\uD83C\uDDF0\uD83C\uDDF7 \u97E9\u56FD\u8282\u70B9') = @{ File = 'region-kr.list'; Rank = 4 }
    (U '\uD83C\uDDE8\uD83C\uDDE6 \u52A0\u62FF\u5927\u8282\u70B9') = @{ File = 'region-ca.list'; Rank = 4 }
    (U '\uD83C\uDDFA\uD83C\uDDF8 \u7F8E\u56FD\u8282\u70B9') = @{ File = 'region-us.list'; Rank = 4 }
    (U '\uD83C\uDDE9\uD83C\uDDEA \u5FB7\u56FD\u8282\u70B9') = @{ File = 'region-de.list'; Rank = 4 }
}

$validTypes = '^(DOMAIN|DOMAIN-SUFFIX|DOMAIN-KEYWORD|IP-CIDR|IP-CIDR6|GEOIP|PROCESS-NAME|SRC-IP-CIDR|DST-PORT|SRC-PORT)$'
$selected = @{}

foreach ($sourceLine in Get-Content -LiteralPath $InputPath -Encoding UTF8) {
    if ($sourceLine -notmatch '^\s*-\s*([^,]+),([^,]+),([^,]+)(.*)$') { continue }
    $type = $Matches[1].Trim()
    $value = $Matches[2].Trim()
    $target = $Matches[3].Trim()
    $tail = $Matches[4].Trim()
    if ($type -notmatch $validTypes -or -not $targetMap.ContainsKey($target)) { continue }

    $mapping = $targetMap[$target]
    $key = "$type,$value".ToLowerInvariant()
    $rule = "$type,$value"
    if ($tail -match '^,no-resolve') { $rule += ',no-resolve' }

    if (-not $selected.ContainsKey($key) -or $mapping.Rank -lt $selected[$key].Rank) {
        $selected[$key] = [pscustomobject]@{ File = $mapping.File; Rank = $mapping.Rank; Rule = $rule }
    }
}

New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
$utf8 = [System.Text.UTF8Encoding]::new($false)
$files = $selected.Values | Group-Object File | Sort-Object Name
foreach ($file in $files) {
    $path = Join-Path $outputDir $file.Name
    $content = @('# Generated from supplied custom rules. Edit source deliberately.') + @($file.Group.Rule | Sort-Object -Unique)
    [System.IO.File]::WriteAllLines($path, $content, $utf8)
    Write-Host "$($file.Name): $($file.Count) rules"
}

Write-Host "Imported $($selected.Count) unique rules into $($files.Count) files"
