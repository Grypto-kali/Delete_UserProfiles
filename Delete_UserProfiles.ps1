# Display menu and script information
function Show-Menu {
    param (
        [string]$Title = 'Automated User Profile Deletion Script V.0.1'
    )
    cls
    Write-Host "================ $Title ================"
    Write-Host "1. Delete all profiles"
    Write-Host "2. Delete profiles older than 30 days"
    Write-Host "3. Delete profiles older than 90 days"
    Write-Host "4. Delete profiles older than 180 days"
    Write-Host "5. Delete profiles older than 365 days"
    Write-Host "0. Exit"
    Write-Host "========================================"
}

# Function to delete user profiles based on the specified date threshold
function Delete-Profiles {
    param (
        [int]$DaysThreshold
    )

    # Retrieve user profiles that are not special profiles and not currently loaded
    $Profiles = Get-WMIObject -class Win32_UserProfile | Where-Object { (!$_.Special) -and (!$_.Loaded) }
    $ProfileNumber = $Profiles.Count
    Write-Host "Number of found user profiles: $ProfileNumber"
    Write-Host "`n"
    Write-Host "Profiles to be deleted (older than $DaysThreshold days):"

    # Delete profiles older than the specified threshold
    If ($ProfileNumber -ne 0) {
        ForEach ($Profile in $Profiles) {
            # Convert the last use time and compare it to the current date
            $LastUseTime = $Profile.ConvertToDateTime($Profile.LastUseTime)
            If ($LastUseTime -lt (Get-Date).AddDays(-$DaysThreshold)) {
                $user = $Profile.LocalPath.Split('\')[2]
                Write-Host "Deleting profile: $user"
                
                # Delete the profile
                $Profile | Remove-WmiObject

                Write-Host "Profile $user has been deleted." -ForegroundColor Red
            }
            else {
                Write-Host "Profile $($Profile.LocalPath.Split('\')[2]) is not older than $DaysThreshold days. Skipping." -ForegroundColor Yellow
            }
        }
    }
    Else {
        Write-Host "No profiles to delete were found."
    }
}

# Display the menu
Show-Menu

# Capture and process user selection
$UserChoice = Read-Host "Select an option (0-5)"
switch ($UserChoice) {
    "1" {
        Write-Host "Deleting all profiles..."
        Delete-Profiles -DaysThreshold 0
    }
    "2" {
        Write-Host "Deleting profiles older than 30 days..."
        Delete-Profiles -DaysThreshold 30
    }
    "3" {
        Write-Host "Deleting profiles older than 90 days..."
        Delete-Profiles -DaysThreshold 90
    }
    "4" {
        Write-Host "Deleting profiles older than 180 days..."
        Delete-Profiles -DaysThreshold 180
    }
    "5" {
        Write-Host "Deleting profiles older than 365 days..."
        Delete-Profiles -DaysThreshold 365
    }
    "0" {
        Write-Host "Exiting script."
        Pause
        Exit
    }
    default {
        Write-Host "Invalid selection. Exiting script."
    }
}

Write-Host "`nScript completed."
Pause
