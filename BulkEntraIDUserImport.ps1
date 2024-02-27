# These are variable you need to update to reflect your environment

$Admin = "INSERTADMINEMAIL@INSERTTENANT.onmicrosoft.com"
$AdminPassword = "INSERT ADMIN PASSWORD HERE!!!!"
$Directory = "INSERTTENANT.onmicrosoft.com"
$NewUserPassword = "INSERT TEMPORARY USER PASSWORDS HERE!!!!"
$CsvFilePath = " INSERT CSV PATH HERE!!!"

# Create a PowerShell connection to your directory

$SecPass = ConvertTo-SecureString $AdminPassword -AsPlainText -Force
$Cred = New-Object System.Management.Automation.PSCredential ($Admin, $SecPass)
Connect-AzureAD -Credential $cred

# Create a new Password Profile for the new users

$PasswordProfile = New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile
$PasswordProfile.Password = $NewUserPassword

# Import the csv file

$NewUsers = Import-Csv -Path $CsvFilePath

# Loop through all new users in the file

foreach ($NewUser in $NewUsers) { 

    # Remove special characters ÅÄÖ from first name and last name
    $FirstName = $NewUser.Firstname -replace '[^a-zA-Z0-9]', ''
    $LastName = $NewUser.LastName -replace '[^a-zA-Z0-9]', ''

    # Construct the UserPrincipalName, the MailNickName, and the DisplayName from the input data in the file 
    $UPN = $FirstName + "." + $LastName + "@" + $Directory
    $DisplayName = $NewUser.Firstname + " " + $NewUser.Lastname + " (" + $NewUser.Department + ")"
    $MailNickName = $FirstName + "." + $LastName

    # Check if Mobilephone is empty or null
    if (![string]::IsNullOrWhiteSpace($NewUser.Mobilephone)) {
        # Create the new user with Mobilephone
        New-AzureADUser -UserPrincipalName $UPN -AccountEnabled $true -DisplayName $DisplayName -GivenName $NewUser.FirstName -MailNickName $MailNickName -Surname $NewUser.LastName -Department $Newuser.Department -TelephoneNumber $Newuser.Officephone -PasswordProfile $PasswordProfile -Mobile $NewUser.Mobilephone
    }
    else {
        # Create the new user without Mobilephone
        New-AzureADUser -UserPrincipalName $UPN -AccountEnabled $true -DisplayName $DisplayName -GivenName $NewUser.FirstName -MailNickName $MailNickName -Surname $NewUser.LastName -Department $Newuser.Department -TelephoneNumber $Newuser.Officephone -PasswordProfile $PasswordProfile
    }
}

# Disconnect from Azure AD
Disconnect-AzureAD
