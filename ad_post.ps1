###########################################################
# COMMENT : This script helps users update the Greetly Directory using a LDAP or Active Directory.
#           The script queries the users information from AD and sends them to Greetly via HTTP Post
#           
###########################################################
# Set credentials of user querying AD
# We recommend not to enter plan text passwords of priviledge accounts
# A restricted service account has enough permissions to query the AD properties Greetly needs
$username = "domain\username"
$password = "password"
#
# Enter your Greetly API KEY
$APIKey="your_greetly_api_key_goes_here"
#
# Sets the OU to do the base search for all user accounts, change as required.
$SearchBase = "CN=Users,DC=your_domain,DC=local"
# Define variable for a server with AD web services installed
$ADServer = 'YOUR_SERVER_NAME'
#
$securePassword = ConvertTo-SecureString $password -AsPlainText -Force
$userCredential = New-Object System.Management.Automation.PSCredential ($username, $securePassword)
#
# Import the ActiveDirectory Module
Import-Module ActiveDirectory
# Filter users if you want to send only active AD users
$filterString = 'enabled -eq $true'
#
$ADUsers = Get-ADUser -server $ADServer -Credential $userCredential -searchbase $SearchBase -Filter $filterString -Properties *
$httpBody =  $ADUsers | Select-Object @{Label = "email";Expression = {$_.Mail}},
@{Label = "first_name";Expression = {$_.GivenName}},
@{Label = "last_name";Expression = {$_.Surname}},
# Since greetly can be adapted to different industries, we suggest using the following field to what better suits your needs
@{Label = "company";Expression = {$_.Title}},
#@{Label = "company";Expression = {$_.Company}},
#@{Label = "company";Expression = {$_.Department}},
@{Label = "sms_phone";Expression = {$_.mobile}},
@{Label = "voice_phone";Expression = {$_.telephoneNumber}} | ConvertTo-Csv -NoTypeInformation 
# These fields are not in AD, but could be stored as custom attributes
#@{Label = "voice_extension";Expression = {$_.customAttribute1}},
#@{Label = "slack_handle";Expression = {$_.customAttribute2}},
#
# Set headers needed by API
$headers = @{"API-KEY"=$APIKey} @{"API-KEY"=$APIKey; "Content-Type" = "text/csv"}
# Set to Greetly via POST
Invoke-WebRequest -Uri https://app.greetly.com/api/directory_services -Method POST -Body $httpBody -Headers $headers

