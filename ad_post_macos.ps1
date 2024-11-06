[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor [System.Net.SecurityProtocolType]::Tls12
Add-Type -AssemblyName System.Web

$username = 'domain\username'
$password = 'password'
$APIKey= "b366bedb78700a1c22e5e4c70b55fc7e1"
$SearchBase = "OU=Users,DC=domain,DC=local"
$SearchScope = "OneLevel"
$ADServer = "domain.local"
$locationName = "Example"
$loactionId = "2"
$asyncParam = "true"
$countryCode = "+1"
$method = "POST" # or "PUT" or "PATCH" or "DELETE"
$hostUrl = "http://localhost:5001" # or "https://greetly-qa.herokuapp.com"

$securePassword = ConvertTo-SecureString $password -AsPlainText -Force
$userCredential = New-Object System.Management.Automation.PSCredential ($username, $securePassword)

$filterString = 'enabled -eq $true'

$ADUsers = @(
    [PSCustomObject]@{
        Mail = "john.doe@example.com"
        GivenName = "John"
        Surname = "Doe"
        Title = "Engineering"
        mobile = "1234567890"
        telephoneNumber = "1234567891"
    },
    [PSCustomObject]@{
        Mail = "jane.smith@example.com"
        GivenName = "Jane"
        Surname = "Smith"
        Title = "Marketing"
        mobile = "1234567892"
        telephoneNumber = "1234567893"
    },
    [PSCustomObject]@{
        Mail = "mike.jones@example.com"
        GivenName = "Mike"
        Surname = "Jones"
        Title = "Sales"
        mobile = "1234567894"
        telephoneNumber = "1234567895"
    },
     [PSCustomObject]@{
         Mail = "invalid_email"
         GivenName = "GivenName"
         Surname = "Surname"
         Title = "Title"
         mobile = "mobile"
         telephoneNumber = "telephoneNumber"
     }
)

$httpBody =  $ADUsers | Select-Object @{Label = "email";Expression = {$_.Mail}},

@{Label = "first_name";Expression = {$_.GivenName}},
@{Label = "last_name";Expression = {$_.Surname}},
@{Label = "company";Expression = {$_.Title}},
@{Label = "sms_phone";Expression = {$countryCode + $_.mobile}},
@{Label = "voice_phone";Expression = {$countryCode + $_.telephoneNumber}} | ConvertTo-Csv -NoTypeInformation

$httpBody = $httpBody -join "`n"

$headers = @{"api-key"=$APIKey;"Content-Type"="text/csv"}
$encondedParam = [System.Web.HttpUtility]::UrlEncode($locationName)
$encondedUrl = "$($hostUrl)/api/directory_services?delayed=$($asyncParam)&location_name=$($encondedParam)&location_id=$($loactionId)&exact_sync=true"

Invoke-WebRequest -Uri $encondedUrl -Method $method -Body $httpBody -Headers $headers
