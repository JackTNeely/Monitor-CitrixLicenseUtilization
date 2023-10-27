<#
.SYNOPSIS
Monitors Citrix license utilization and sends email alerts when the usage exceeds a specified threshold.

.DESCRIPTION
This script retrieves license usage information for all license types, calculates the license usage percentage, and sends an email alert if the usage exceeds a specified threshold. It also outputs detailed usage information for all license types to the console and/or a specified file.

.PARAMETER CitrixLicenseServer
Name or IP address of Citrix License Server.

.PARAMETER LicenseTypes
Array of license types to monitor.

.PARAMETER Threshold
License usage percentage threshold for sending email alerts.

.PARAMETER OutputFile
Path to output file for detailed license usage information.

.PARAMETER EmailFrom
Email address to send alerts from.

.PARAMETER EmailTo
Email addresses to send alerts to.

.PARAMETER EmailServer
SMTP server to use for sending email alerts.

.PARAMETER LogFile
Path to log file for script execution information.

.PARAMETER UseSsl
Use SSL/TLS encryption for email alerts.

.PARAMETER HtmlBody
Send email alerts with HTML body.

.PARAMETER ProductEdition
Product edition to monitor.

.PARAMETER UserGroup
User group to monitor.

.EXAMPLE
.\Monitor-CitrixUtilization.ps1 -CitrixLicenseServer 'Server01' -LicenseTypes @('XenApp', 'XenDesktop') -Threshold 90 -OutputFile 'C:\LicenseUsage.csv' -EmailFrom 'alert@domain.com' -EmailTo 'user1@domain.com', 'user2@domain.com' -EmailServer 'smtpserver' -LogFile 'C:\Monitor-CitrixUtilization.log' -UseSsl -HtmlBody -ProductEdition 'XenApp' -UserGroup 'Domain\Group'

#>

param (
    [parameter(Mandatory=$true, HelpMessage='Name or IP address of Citrix License Server')]
    [string]$CitrixLicenseServer,

    [parameter(Mandatory=$true, HelpMessage='Array of license types to monitor')]
    [string[]]$LicenseTypes,

    [parameter(Mandatory=$true, HelpMessage='License usage percentage threshold for sending email alerts')]
    [int]$Threshold,

    [parameter(HelpMessage='Path to output file for detailed license usage information')]
    [string]$OutputFile,

    [parameter(Mandatory=$true, HelpMessage='Email address to send alerts from')]
    [string]$EmailFrom,

    [parameter(Mandatory=$true, HelpMessage='Email addresses to send alerts to')]
    [string[]]$EmailTo,

    [parameter(Mandatory=$true, HelpMessage='SMTP server to use for sending email alerts')]
    [string]$EmailServer,

    [parameter(HelpMessage='Path to log file for script execution information')]
    [string]$LogFile,

    [parameter(HelpMessage='Use SSL/TLS encryption for email alerts')]
    [switch]$UseSsl,

    [parameter(HelpMessage='Send email alerts with HTML body')]
    [switch]$HtmlBody,

    [parameter(HelpMessage='Product edition to monitor')]
    [string]$ProductEdition,

    [parameter(HelpMessage='User group to monitor')]
    [string]$UserGroup
)

# Sends an email alert if the license usage exceeds the specified threshold
function Send-LicenseUsageEmail {
    param (
        [string]$From,
        [string[]]$To,
        [string]$Server,
        [int]$Total,
        [int]$InUse,
        [double]$Percent
    )

    $subject = "ALERT: Citrix License Usage for $Server"
    if ($ProductEdition) {
        $subject += " ($ProductEdition)"
    }
    $body = "Warning! Citrix license usage has reached $Percent%. Total Licenses: $Total, Licenses In Use: $InUse."
    $params = @{
        To = $To
        Subject = $subject
        Body = $body
        SmtpServer = $EmailServer
        From = $From
    }
    if ($UseSsl) {
        $params['UseSsl'] = $true
    }
    if ($HtmlBody) {
        $params['BodyAsHtml'] = $true
    }
    Send-MailMessage @params
}

# Retrieves license usage information for all license types and outputs detailed usage information to the console and/or a specified file
function Get-LicenseUsageDetails {
    # Get Citrix Licensing Info from WMI
    try {
        $LicensePool = Get-WmiObject -Class "Citrix_GT_License_Pool" -Namespace "ROOT\CitrixLicensing" -ComputerName $CitrixLicenseServer -ErrorAction Stop | Where-Object { $_.PLD -eq $ProductEdition }
    }
    catch {
        $ErrorMessage = "An error occurred while retrieving license usage information: $_"
        Write-Error $ErrorMessage
        if ($LogFile) {
            $ErrorMessage | Tee-Object -FilePath $LogFile -Append
        }
        Send-MailMessage -To $EmailTo -Subject "ERROR: Citrix License Usage Monitoring Script" -Body "An error occurred while retrieving license usage information. Please check the log file for details." -SmtpServer $EmailServer -From $EmailFrom -UseSsl:$UseSsl -BodyAsHtml:$HtmlBody
        return
    }

    # Calculate license usage percentage for each license type
    foreach ($LicenseType in $LicenseTypes) {
        $LicenseInfo = $LicensePool | Where-Object { $_.PLD -eq $LicenseType }

        # Calculate percentage of licenses in use
        $LicenseUsagePercentage = if ($LicenseInfo.Count -eq 0) { 0 } else { [Math]::Round(($LicenseInfo.InUseCount / $LicenseInfo.Count) * 100, 2) }

        # Output detailed license usage information to console and/or a specified file
        Write-Host "License Type: $LicenseType"
        Write-Host "Total Licenses: $($LicenseInfo.Count)"
        Write-Host "Licenses In Use: $($LicenseInfo.InUseCount)"
        Write-Host "Percentage of Licenses Used: $LicenseUsagePercentage%"

        if ($OutputFile) {
            $LicenseInfo | Select-Object PLD, InUseCount, @{Name='Licenses Available';Expression={$_.Count - $_.InUseCount}} | Export-Csv -Path $OutputFile -Append -NoTypeInformation
        }

        # Send email alert if the license usage exceeds the specified threshold
        if ($LicenseUsagePercentage -ge $Threshold) {
            Send-LicenseUsageEmail -From $EmailFrom -To $EmailTo -Server $CitrixLicenseServer -Total $LicenseInfo.Count -InUse $LicenseInfo.InUseCount -Percent $LicenseUsagePercentage
        }
    }
}

# Retrieves license usage information for a specific user group
function Get-UserGroupLicenseUsage {
    # Get Citrix Licensing Info from WMI
    try {
        $LicensePool = Get-WmiObject -Class "Citrix_GT_License_Pool" -Namespace "ROOT\CitrixLicensing" -ComputerName $CitrixLicenseServer -ErrorAction Stop | Where-Object { $_.PLD -eq $ProductEdition }
    }
    catch {
        $ErrorMessage = "An error occurred while retrieving license usage information: $_"
        Write-Error $ErrorMessage
        if ($LogFile) {
            $ErrorMessage | Tee-Object -FilePath $LogFile -Append
        }
        Send-MailMessage -To $EmailTo -Subject "ERROR: Citrix License Usage Monitoring Script" -Body "An error occurred while retrieving license usage information. Please check the log file for details." -SmtpServer $EmailServer -From $EmailFrom -UseSsl:$UseSsl -BodyAsHtml:$HtmlBody
        return
    }

    # Calculate license usage for the specified user group
    $UserGroupLicenseUsage = $LicensePool | Where-Object { $_.UserGroup -eq $UserGroup } | Measure-Object -Property InUseCount, Count -Sum | Select-Object @{Name='Licenses In Use';Expression={$_.Sum - $_.Count}}, Count

    # Output user group license usage information to console and/or a specified file
    Write-Host "User Group: $UserGroup"
    Write-Host "Total Licenses: $($UserGroupLicenseUsage.Count)"
    Write-Host "Licenses In Use: $($UserGroupLicenseUsage.'Licenses In Use')"
    Write-Host "Percentage of Licenses Used: $([Math]::Round(($UserGroupLicenseUsage.'Licenses In Use' / $UserGroupLicenseUsage.Count) * 100, 2))%"

    if ($OutputFile) {
        $UserGroupLicenseUsage | Select-Object Count, @{Name='Licenses In Use';Expression={$_.Sum - $_.Count}}, @{Name='Licenses Available';Expression={$_.Count - ($_.Sum - $_.Count)}} | Export-Csv -Path $OutputFile -Append -NoTypeInformation
    }

    # Send email alert if the license usage exceeds the specified threshold
    if ($UserGroupLicenseUsage.'Licenses In Use' / $UserGroupLicenseUsage.Count * 100 -ge $Threshold) {
        Send-LicenseUsageEmail -From $EmailFrom -To $EmailTo -Server $CitrixLicenseServer -Total $UserGroupLicenseUsage.Count -InUse $UserGroupLicenseUsage.'Licenses In Use' -Percent ([Math]::Round(($UserGroupLicenseUsage.'Licenses In Use' / $UserGroupLicenseUsage.Count) * 100, 2))
    }
}

# Main script execution
try {
    # Initialize log file
    if ($LogFile) {
        $LogMessage = "Starting script execution at $(Get-Date)"
        Write-Output $LogMessage | Tee-Object -FilePath $LogFile -Append
    }

    if ($UserGroup) {
        # Retrieve license usage information for a specific user group
        Get-UserGroupLicenseUsage
    }
    else {
        # Retrieve license usage information for all license types
        Get-LicenseUsageDetails
    }

    # Log successful script execution
    if ($LogFile) {
        $LogMessage = "Script execution completed successfully at $(Get-Date)"
        Write-Output $LogMessage | Tee-Object -FilePath $LogFile -Append
    }
}
catch {
    # Log error message
    $ErrorMessage = "An error occurred: $_"
    Write-Error $ErrorMessage
    if ($LogFile) {
        $ErrorMessage | Tee-Object -FilePath $LogFile -Append
    }

    # Send email alert for error
    Send-MailMessage -To $EmailTo -Subject "ERROR: Citrix License Usage Monitoring Script" -Body "An error occurred while monitoring Citrix license usage. Please check the log file for details." -SmtpServer $EmailServer -From $EmailFrom -UseSsl:$UseSsl -BodyAsHtml:$HtmlBody
}
