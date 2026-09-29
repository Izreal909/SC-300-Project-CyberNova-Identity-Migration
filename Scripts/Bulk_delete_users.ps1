# Re-authenticate to ensure your token is fresh
Connect-MgGraph -Scopes "User.ReadWrite.All"

# Define the path to your CSV file
$csvPath = "./EntraID_Bulk_Create_Users.csv"

# Read the CSV, skipping the first line (instructional header from Entra templates)
$users = Get-Content $csvPath | Select-Object -Skip 1 | ConvertFrom-Csv

# Define your verified tenant domain
$targetDomain = "Izreal909.onmicrosoft.com"

$successCount = 0
$skipCount = 0
$failCount = 0

Write-Host "Starting Identity Bulk Deletion..." -ForegroundColor Cyan

foreach ($user in $users) {
    # 1. Swap the domain to match your verified tenant (same as creation script)
    $rawUpn = $user."User name [userPrincipalName] Required"
    $upn = $rawUpn -replace "@cybernova.onmicrosoft.com", "@$targetDomain"
    
    # 2. Check if the user exists before attempting to delete
    # Using -UserId with the UPN is faster and more direct than a -Filter
    $existingUser = Get-MgUser -UserId $upn -ErrorAction SilentlyContinue

    if (-not $existingUser) {
        Write-Host "[-] SKIPPED: $upn does not exist (already deleted or never created)." -ForegroundColor DarkYellow
        $skipCount++
        continue 
    }

    # 3. Attempt deletion
    try {
        Write-Host "[x] DELETING: $upn..." -NoNewline
        
        # Remove-MgUser accepts the UPN directly via the -UserId parameter
        Remove-MgUser -UserId $upn -ErrorAction Stop

        Write-Host " SUCCESS" -ForegroundColor Green
        $successCount++
    } catch {
        Write-Host " FAILED" -ForegroundColor Red
        Write-Host "    Error: $($_.Exception.Message)" -ForegroundColor Red
        $failCount++
    }
}

Write-Host "`n--- Deletion Complete ---" -ForegroundColor Cyan
Write-Host "Successfully Deleted: $successCount" -ForegroundColor Green
Write-Host "Skipped (Not Found): $skipCount" -ForegroundColor DarkYellow
Write-Host "Failed: $failCount" -ForegroundColor Red