# Essay File Organization Script
# UTF-8 BOM encoding for Japanese characters

$essayDir = "d:\Obsidian\creative-comp\04_knowledge\personal_essays"
$backupDir = "d:\Obsidian\creative-comp\04_knowledge\personal_essays\_backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"

Write-Host "=== Essay File Organization Script ===" -ForegroundColor Cyan
Write-Host ""

# 1. Create Backup Directory
Write-Host "1. Creating backup..." -ForegroundColor Yellow
New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
Get-ChildItem $essayDir -Filter "*.md" | ForEach-Object {
    Copy-Item $_.FullName -Destination $backupDir
}
Write-Host "   Backup completed: $backupDir" -ForegroundColor Green
Write-Host ""

# 2. Delete Duplicate Files
Write-Host "2. Removing duplicate files..." -ForegroundColor Yellow
$duplicates = @(
    "vol68_2022-05_金太郎飴のように.md",
    "vol69_2022-06_観客の心持ち.md",
    "vol70_2022-07_本名あっての芸名〜私の芸名は「コンプレッサー」.md",
    "vol71_2022-08_本物と偽物.md",
    "vol71_2022-09_人生初のマジックライブで学んだこと.md"
)

$deletedCount = 0
foreach ($file in $duplicates) {
    $path = Join-Path $essayDir $file
    if (Test-Path $path) {
        $size = (Get-Item $path).Length
        if ($size -eq 0 -or $size -lt 100) {
            Remove-Item $path -Force
            Write-Host "   Deleted: $file (size: $size bytes)" -ForegroundColor Green
            $deletedCount++
        }
        else {
            Write-Host "   Skipped (has content): $file (size: $size bytes)" -ForegroundColor Yellow
        }
    }
}
Write-Host "   Total deleted: $deletedCount files" -ForegroundColor Green
Write-Host ""

# 3. Add YAML Frontmatter
Write-Host "3. Adding YAML frontmatter..." -ForegroundColor Yellow
$processed = 0
$skipped = 0

Get-ChildItem $essayDir -Filter "vol*.md" | ForEach-Object {
    $content = Get-Content $_.FullName -Raw -Encoding UTF8
    
    # Skip if already has YAML frontmatter
    if ($content -match '^---[\r\n]') {
        $skipped++
        return
    }
    
    # Extract info from filename
    $filename = $_.BaseName
    if ($filename -match '^vol(\d+)_(\d{4})-(\d{2})(?:-(\d{2}))?_(.+)$') {
        $volume = $matches[1]
        $year = $matches[2]
        $month = $matches[3]
        $day = if ($matches[4]) { $matches[4] } else { "01" }
        $titleFromFilename = $matches[5]
        
        # Get title from first line
        $lines = $content -split "[\r\n]+" | Where-Object { $_.Trim() -ne "" }
        $firstLine = $lines[0].Trim()
        
        # Clean title
        if ($firstLine -and $firstLine.Length -gt 0 -and $firstLine -notmatch '^\d{4}') {
            $cleanTitle = $firstLine
        }
        else {
            $cleanTitle = $titleFromFilename
        }
        
        # Extract date from content
        foreach ($line in $lines[0..10]) {
            if ($line -match '(\d{4})年(\d{1,2})月(\d{1,2})日') {
                $year = $matches[1]
                $month = "{0:D2}" -f [int]$matches[2]
                $day = "{0:D2}" -f [int]$matches[3]
                break
            }
        }
        
        # Create YAML frontmatter
        $yaml = "---`r`n"
        $yaml += "title: `"$cleanTitle`"`r`n"
        $yaml += "date: ${year}年${month}月${day}日`r`n"
        $yaml += "volume: $volume`r`n"
        $yaml += "url: https://comp-office.com/essay/${year}-${month}/`r`n"
        $yaml += "tags:`r`n"
        $yaml += "  - エッセイ`r`n"
        $yaml += "  - コンプレッサー通信`r`n"
        $yaml += "---`r`n`r`n"
        
        # Add heading if not present
        if ($content -notmatch '^#\s') {
            $yaml += "# $cleanTitle`r`n`r`n"
        }
        
        # Skip metadata lines and add body
        $bodyStartIndex = 0
        for ($i = 0; $i -lt $lines.Count; $i++) {
            if ($lines[$i] -match 'コンプレサー通信' -or $lines[$i] -match 'vol\.\d+') {
                $bodyStartIndex = $i + 1
                break
            }
        }
        
        if ($bodyStartIndex -gt 0 -and $bodyStartIndex -lt $lines.Count) {
            $body = ($lines[$bodyStartIndex..($lines.Count - 1)] -join "`r`n").Trim()
            $newContent = $yaml + $body
        }
        else {
            $newContent = $yaml + $content
        }
        
        # Write to file
        [System.IO.File]::WriteAllText($_.FullName, $newContent, [System.Text.UTF8Encoding]::new($false))
        $processed++
        Write-Host "   Processed: $($_.Name)" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "   Processed: $processed files" -ForegroundColor Green
Write-Host "   Skipped: $skipped files (already formatted)" -ForegroundColor Cyan
Write-Host ""

# 4. Summary
Write-Host "=== Completed ===" -ForegroundColor Cyan
$totalFiles = (Get-ChildItem $essayDir -Filter "vol*.md").Count
Write-Host "Total files: $totalFiles" -ForegroundColor White
Write-Host "Backup location: $backupDir" -ForegroundColor White
Write-Host ""
