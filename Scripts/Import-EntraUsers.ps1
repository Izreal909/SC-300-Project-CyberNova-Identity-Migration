# Re-authenticate to ensure your token is fresh
Connect-MgGraph -Scopes "User.ReadWrite.All", "User.Read.All"

$csvPath = "./EntraID_Bulk_Create_Users.csv"
$users = Get-Content $csvPath | Select-Object -Skip 1 | ConvertFrom-Csv

# Define your verified tenant domain
$targetDomain = "Izreal909.onmicrosoft.com"

$successCount = 0
$skipCount = 0
$failCount = 0

Write-Host "Starting Identity Provisioning Sync with MailNickname Fix..." -ForegroundColor Cyan

foreach ($user in $users) {
    # 1. Swap the domain to your verified tenant
    $rawUpn = $user."User name [userPrincipalName] Required"
    $upn = $rawUpn -replace "@cybernova.onmicrosoft.com", "@$targetDomain"
    
    # 2. EXTRACT MAIL NICKNAME (Grabs everything before the @ symbol)
    $mailNickname = ($upn -split "@")[0]
    
    # 3. Check if the user already exists
    $existingUser = Get-MgUser -Filter "userPrincipalName eq '$upn'" -ErrorAction SilentlyContinue

    if ($existingUser) {
        Write-Host "[-] SKIPPED: $upn already exists." -ForegroundColor DarkYellow
        $skipCount++
        continue 
    }

    # 4. Prep attributes for the new user
    $accountEnabled = if ($user."Block sign in (Yes/No) [accountEnabled] Required" -eq "No") { $true } else { $false }
    $passwordProfile = @{
        Password = $user."Initial password [passwordProfile] Required"
        ForceChangePasswordNextSignIn = $true
    }

    # 5. Attempt creation with the required -MailNickname parameter included
    try {
        Write-Host "[+] PROVISIONING: $upn..." -NoNewline
        
        New-MgUser -DisplayName $user."Name [displayName] Required" `
                   -UserPrincipalName $upn `
                   -MailNickname $mailNickname `
                   -GivenName $user."First name [givenName]" `
                   -Surname $user."Last name [surname]" `
                   -JobTitle $user."Job title [jobTitle]" `
                   -Department $user."Department [department]" `
                   -UsageLocation $user."Usage location [usageLocation]" `
                   -AccountEnabled:$accountEnabled `
                   -PasswordProfile $passwordProfile | Out-Null

        Write-Host " SUCCESS" -ForegroundColor Green
        $successCount++
    } catch {
        Write-Host " FAILED" -ForegroundColor Red
        Write-Host "    Error: $($_.Exception.Message)" -ForegroundColor Red
        $failCount++
    }
}

Write-Host "`n--- Sync Complete ---" -ForegroundColor Cyan
Write-Host "Successfully Created: $successCount" -ForegroundColor Green
Write-Host "Skipped (Already Existed): $skipCount" -ForegroundColor DarkYellow
Write-Host "Failed: $failCount" -ForegroundColor Red