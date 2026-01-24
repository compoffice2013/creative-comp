# Fix YAML encoding issues
# This script fixes the encoding problems in YAML frontmatter

$essayDir = "d:\Obsidian\creative-comp\04_knowledge\personal_essays"

Write-Host "=== Fixing YAML Encoding Issues ===" -ForegroundColor Cyan
Write-Host ""

$fixed = 0
$errors = 0

Get-ChildItem $essayDir -Filter "vol*.md" | ForEach-Object {
    try {
        # Read file with UTF8 encoding
        $content = [System.IO.File]::ReadAllText($_.FullName, [System.Text.Encoding]::UTF8)
        
        # Fix common encoding issues in YAML
        $originalContent = $content
        $content = $content -replace '蟷ｴ', '年'
        $content = $content -replace '譛・', '月'
        $content = $content -replace '譌･', '日'
        $content = $content -replace '繧ｨ繝・そ繧､', 'エッセイ'
        $content = $content -replace '繧ｳ繝ｳ繝励Ξ繝・し繝ｼ騾壻ｿ｡', 'コンプレッサー通信'
        $content = $content -replace '\{day\}', '01'
        
        # Only write if changes were made
        if ($content -ne $originalContent) {
            [System.IO.File]::WriteAllText($_.FullName, $content, [System.Text.UTF8Encoding]::new($false))
            Write-Host "   Fixed: $($_.Name)" -ForegroundColor Green
            $fixed++
        }
    }
    catch {
        Write-Host "   Error: $($_.Name) - $($_.Exception.Message)" -ForegroundColor Red
        $errors++
    }
}

Write-Host ""
Write-Host "=== Summary ===" -ForegroundColor Cyan
Write-Host "Fixed: $fixed files" -ForegroundColor Green
if ($errors -gt 0) {
    Write-Host "Errors: $errors files" -ForegroundColor Red
}
Write-Host ""
