# Monitor-CitrixLicenseUtilization
PowerShell script for monitoring Citrix license utilization and sending email alerts when the usage exceeds a specified threshold.

```markdown
# Citrix License Usage Monitoring Script

This PowerShell script retrieves license usage information from a Citrix License Server using WMI and sends email alerts if license usage exceeds a specified threshold.

## Requirements

- PowerShell 2.0 or later
- Citrix Licensing Service running on a Citrix License Server
- Windows Firewall configured to allow remote WMI access

## Usage

To use the script, run the `Monitor-CitrixLicenseUtilization.ps1` script file with the following parameters:

- `CitrixLicenseServer`: The name of the Citrix License Server to retrieve license usage information from.
- `Threshold`: The license usage threshold (in percentage) at which to send email alerts.
- `OutputFile`: The path to the CSV file to save license usage information to.
- `EmailFrom`: The email address to send email alerts from.
- `EmailTo`: An array of email addresses to send email alerts to.
- `EmailServer`: The SMTP server to use to send email alerts.
- `EmailPort`: The SMTP server port to use to send email alerts (default is 25).
- `LogFile`: The path to the log file to save script execution information to.

For example:

```powershell
.\Monitor-CitrixLicenseUtilization.ps1 -CitrixLicenseServer 'Server01' -Threshold 90 -OutputFile 'C:\LicenseUsage.csv' -EmailFrom 'alert@domain.com' -EmailTo 'user1@domain.com', 'user2@domain.com' -EmailServer 'smtpserver' -LogFile 'C:\Monitor-CitrixUtilization.log'
```

## Output File Format

The output file will contain detailed license usage information for all license types. Each row represents a license type and includes the following columns: License Type, Total Licenses, Licenses In Use, and License Usage Percentage.

Here's an example of what the output file might look like:

```csv
License Type,Total Licenses,Licenses In Use,License Usage Percentage
XenApp Enterprise,100,80,80%
XenDesktop Platinum,50,30,60%
NetScaler Gateway Universal,200,150,75%
```

In this example, the script has retrieved license usage information for three license types: XenApp Enterprise, XenDesktop Platinum, and NetScaler Gateway Universal. The script has calculated the license usage percentage for each license type and output the results to the specified output file.

## Troubleshooting

To troubleshoot issues when running the Citrix License Usage Monitoring Script, you can follow these steps:

1. Refer to the script output and log files for more information about the error. The script outputs detailed information about license usage and any errors that occur during script execution. The log file also contains information about when the script was executed and where the license usage information was saved.

2. Consult the Citrix License Server documentation for more information about how to configure and troubleshoot the Citrix Licensing Service. The Citrix documentation provides detailed information about how to configure the Citrix Licensing Service to use WMI and how to allow remote WMI access.

3. Seek assistance from Citrix support if you are unable to resolve the issue using the script output, log files, or Citrix documentation. Citrix support can provide additional assistance with troubleshooting and resolving issues related to the Citrix Licensing Service and Citrix License Server.

By following these steps, you should be able to troubleshoot and resolve most issues that occur when running the Citrix License Usage Monitoring Script.

To configure the Citrix Licensing Service to use WMI and allow remote WMI access, you can follow these steps:

1. Open the Citrix Licensing Manager on the Citrix License Server.

2. Click on the "Configuration" tab.

3. Under "Service Options", select "Use WMI for Remote Administration".

4. Click on the "Security" tab.

5. Under "WMI Security", select "Enable Remote WMI".

6. Click on the "Apply" button to save the changes.

7. Open the Windows Firewall on the Citrix License Server.

8. Click on "Advanced Settings".

9. Click on "Inbound Rules".

10. Click on "New Rule".

11. Select "WMI" from the list of predefined rules.

12. Click on "Next".

13. Select "Allow the connection".

14. Click on "Next".

15. Select the network types for which the rule should apply.

16. Click on "Next".

17. Give the rule a name and click on "Finish".

By following these steps, you should be able to configure the Citrix Licensing Service to use WMI and allow remote WMI access. This will allow the Citrix License Usage Monitoring Script to retrieve license usage information from the Citrix License Server using WMI.

To configure the script to run at regular intervals using Windows Task Scheduler, you can follow these steps:

1. Open Task Scheduler by typing "Task Scheduler" in the Start menu search bar and selecting the "Task Scheduler" app.

2. Click on "Create Task" in the "Actions" pane on the right-hand side of the Task Scheduler window.

3. In the "General" tab, give the task a name and description.

4. In the "Triggers" tab, click "New" to create a new trigger.

5. In the "New Trigger" window, specify the schedule for the task. For example, you can set it to run daily at a specific time.

6. In the "Actions" tab, click "New" to create a new action.

7. In the "New Action" window, select "Start a program" as the action type.

8. In the "Program/script" field, specify the path to the PowerShell executable (usually `C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe`).

9. In the "Add arguments" field, specify the path to the script file and any required parameters. For example:

   ```powershell
   -ExecutionPolicy Bypass -File "C:\Scripts\Monitor-CitrixLicenseUtilization.ps1" -CitrixLicenseServer 'Server01' -Threshold 90 -OutputFile 'C:\LicenseUsage.csv' -EmailFrom 'alert@domain.com' -EmailTo 'user1@domain.com', 'user2@domain.com' -EmailServer 'smtpserver' -LogFile 'C:\Monitor-CitrixUtilization.log'
   ```

   Note that you may need to adjust the paths and parameters to match your environment.

10. Click "OK" to save the new task.

The script will now run automatically at the specified intervals. You can view the status of the task in the "Task Scheduler Library" pane of the Task Scheduler window.

You can also modify the task settings by right-clicking on the task in the "Task Scheduler Library" pane and selecting "Properties". From here, you can modify the task schedule, action, and other settings as needed.

## License

This script is licensed under the MIT License. See the [LICENSE](LICENSE) file for more information.
```
