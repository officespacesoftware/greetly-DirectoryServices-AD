###########################################################
# COMMENT : This script updates the Greetly Directory using a LDAP or Active Directory.
#           The script queries users information from AD and sends them to Greetly via HTTP POST.
#           
###########################################################
#           
# In order to use this script, you need to update the following variables
# username: We recommend not to enter plan text passwords of priviledge accounts. A restricted service account has enough permissions to query the AD properties Greetly needs
# password: The password of the account above.
# APIKey: Your API-KEY provided by Greetly. You can find this on the Account Settings page.
# SearchBase: The OU in AD where users will be retrived from
# ADServer: The name of AD server queries will be performed against
# 
$username = "domain\username"
$password = "password"
$APIKey="your_greetly_api_key_goes_here"
$SearchBase = "CN=Users,DC=your_domain,DC=local"
$ADServer = 'YOUR_SERVER_NAME'
$locationName = "name_of_location_to_be_updated"
#
###########################################################
#
$securePassword = ConvertTo-SecureString $password -AsPlainText -Force
$userCredential = New-Object System.Management.Automation.PSCredential ($username, $securePassword)
#           
# Import the ActiveDirectory Module
Import-Module ActiveDirectory
#           
# Filter users if you want to send only active AD users
$filterString = 'enabled -eq $true'
#           
$ADUsers = Get-ADUser -server $ADServer -Credential $userCredential -searchbase $SearchBase -Filter $filterString -Properties *
$httpBody =  $ADUsers | Select-Object @{Label = "email";Expression = {$_.Mail}},
@{Label = "first_name";Expression = {$_.GivenName}},
@{Label = "last_name";Expression = {$_.Surname}},
#           
# Since greetly can be adapted to different industries, we suggest using the following field to what better suits your needs
@{Label = "company";Expression = {$_.Title}},
#@{Label = "company";Expression = {$_.Company}},
#@{Label = "company";Expression = {$_.Department}},
@{Label = "sms_phone";Expression = {$_.mobile}},
@{Label = "voice_phone";Expression = {$_.telephoneNumber}} | ConvertTo-Csv -NoTypeInformation 
#           
# These fields are not in AD, but could be stored as custom attributes
#@{Label = "voice_extension";Expression = {$_.customAttribute1}},
#@{Label = "slack_handle";Expression = {$_.customAttribute2}},
#           
$httpBody = $httpBody -join "`n"
#           
# Set headers needed by API
$headers = @{"api-key"=$APIKey;"Content-Type"="text/csv"}
$encondedParam = [System.Web.HttpUtility]::UrlEncode($locationName) 
$encondedUrl = "https://app.greetly.com/api/directory_services?location_name=$encondedParam"
#           
# Uncomment the line below if you would like to review the data that will be sent first
# Write-Host $httpBody
#           
# Set to Greetly via POST
Invoke-WebRequest -Uri $encondedUrl -Method POST -Body $httpBody -Headers $headers

