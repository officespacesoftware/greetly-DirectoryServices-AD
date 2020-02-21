# DirectoryServices-AD

We developed a PowerShell script that allows you to send Greetly your Active Directory users via HTTPS. You can schedule this script to run as a job on your environment. All you have to do is update the variables in the script with your AD and Greetly information.

This script updates the Greetly Directory using a LDAP or Active Directory. It queries users information from AD and sends them to Greetly via HTTP POST.
     
In order to use this script, you need to update the following variables
- username: We recommend not to enter plan text passwords of priviledge accounts. A restricted service account has enough permissions to query the AD properties Greetly needs
- password: The password of the account above.
- APIKey: Your API-KEY provided by Greetly. You can find this on the Account Settings page.
- SearchBase: The OU in AD where users will be retrived from
- ADServer: The name of AD server queries will be performed against

If you are not familiar with PowerShell, we recommed reviewing the following tutorial: https://blog.netwrix.com/2018/02

# NOTE

For non-servers this requires Remote Server Administration Tools for Windows. The required PowerShell plug-in can be downloaded from the following URLs:

- Windows 7: http://www.microsoft.com/en-us/download/details.aspx?id=7887
- Windows 8: http://www.microsoft.com/en-us/download/details.aspx?id=28972
- Windows 10: https://www.microsoft.com/en-au/download/details.aspx?id=45520

