
#
# 6. Users
# massivedynamic.local
#
# Each faculty: 850 Students, 25 Professors, 15 Associates, 5 HR, 5 Secretary
# Total: 900 users x 4 faculties = 3600 users
#
# Call example after loading the function:
#
# Create-ADLabUsers -Domain "massivedynamic.local" `
#                   -NumberOfADUserAccounts 3400 `
#                   -FirstNameFile "C:\Scripts\first_names.csv" `
#                   -LastNameFile "C:\Scripts\last_names.csv" `
#                   -Title "Student" `
#                   -NameFormatLayout "FLast"
#
# Run once per Title type, adjusting NumberOfADUserAccounts each time:
# Students   -> 3400 (850 x 4)
# Professors -> 100  (25  x 4)
# Associates -> 60   (15  x 4)
# HR         -> 20   (5   x 4)
# Secretary  -> 20   (5   x 4)
# ============================================================

function New-RandomPassword
{
    $Lower   = 'abcdefghijklmnopqrstuvwxyz'
    $Upper   = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
    $Numbers = '0123456789'
    $Special = '!@#$%^&*()'

    $PasswordLength = Get-Random -Minimum 12 -Maximum 17

    $PasswordChars = @()

    $PasswordChars += $Lower[(Get-Random -Maximum $Lower.Length)]
    $PasswordChars += $Upper[(Get-Random -Maximum $Upper.Length)]
    $PasswordChars += $Numbers[(Get-Random -Maximum $Numbers.Length)]
    $PasswordChars += $Special[(Get-Random -Maximum $Special.Length)]

    $AllChars = $Lower + $Upper + $Numbers + $Special

    for ($i = 4; $i -lt $PasswordLength; $i++)
    {
        $PasswordChars += $AllChars[(Get-Random -Maximum $AllChars.Length)]
    }

    -join ($PasswordChars | Sort-Object { Get-Random })
}

Function Create-ADLabUsers
{
    Param
    (
        [Parameter(Mandatory=$true)]$Domain,
        [Parameter(Mandatory=$true)][int]$NumberOfADUserAccounts,
        [Parameter(Mandatory=$true)]$FirstNameFile,
        [Parameter(Mandatory=$true)]$LastNameFile,
        [Parameter(Mandatory=$true)]$Title,
        [ValidateSet('Random', 'FLast')][String]$NameFormatLayout = 'FLast'
    )

    # EqualDistribution = users per faculty
    # NumberOfUsers = total across all four faculties
    $EqualDistribution = $NumberOfADUserAccounts / 4
    SWITCH ($Title)
    {
        'Student'   { $NumberOfUsers = $EqualDistribution * 4 }
        'Professor' { $NumberOfUsers = $EqualDistribution * 4 }
        'Associate' { $NumberOfUsers = $EqualDistribution * 4 }
        'HR'        { $NumberOfUsers = $EqualDistribution * 4 }
        'Secretary' { $NumberOfUsers = $EqualDistribution * 4 }
        Default     { $NumberOfUsers = 0 }
    }

    $DomainDC       = (Get-ADDomainController -Discover -DomainName $Domain).Name
    $FirstNameArray = Import-CSV $FirstNameFile
    $LastNameArray  = Import-CSV $LastNameFile
    $DomainInfo     = Get-ADDomain -Server $DomainDC

# Distinguished name = DC=massivedynamic,DC=local
    SWITCH ($Title)
    {
        'Student'   { $UserOU = "OU=Students,OU=Users" }
        'Professor' { $UserOU = "OU=Professors,OU=Employees,OU=Users" }
        'Associate' { $UserOU = "OU=Associates,OU=Employees,OU=Users" }
        'HR'        { $UserOU = "OU=HR,OU=Staff,OU=Employees,OU=Users" }
        'Secretary' { $UserOU = "OU=Secretary,OU=Staff,OU=Employees,OU=Users" }
        Default     { $UserOU = "Users" }
    }

    # UniversitySize = users per faculty, used to assign faculty in the loop
    $UniversitySize = $NumberOfUsers / 4

    [int]$UserAccountLoopCount = 1

    Do
    {
        IF      ($UserAccountLoopCount -le $UniversitySize)
            { $University = "Civil Engineering" }
        elseIF  ($UserAccountLoopCount -le $UniversitySize * 2)
            { $University = "Electrical Engineering" }
        elseIF  ($UserAccountLoopCount -le $UniversitySize * 3)
            { $University = "Mechanical Engineering" }
        else
            { $University = "Architecture" }

        $FirstRandom = Get-Random -Minimum 0 -Maximum 999
        $LastRandom  = Get-Random -Minimum 0 -Maximum 99

        $UserFirstName        = ($FirstNameArray[$FirstRandom]).Name
        $UserLastName         = ($LastNameArray[$LastRandom]).Name
        $UserFirstInitialName = $UserFirstName.Substring(0, 1).ToLower()

        SWITCH ($NameFormatLayout)
        {
            'FLast'  { $TestUserAccount = $UserFirstInitialName + $UserLastName.ToLower() }
            Default  { $TestUserAccount = $UserFirstInitialName + $UserLastName.ToLower() }
        }

        $DuplicateCount = 1
        $OriginalTestUserAccount = $TestUserAccount
        WHILE (Get-ADUser -Filter "SamAccountName -eq '$TestUserAccount'")
        {
            $TestUserAccount = $OriginalTestUserAccount + $DuplicateCount
            $DuplicateCount++
        }

        Write-Host "Creating lab user $TestUserAccount (#$UserAccountLoopCount out of $NumberOfUsers)" -ForegroundColor Cyan

        $HomeDir    = $null
        $HomeDrive  = $null
        $EmployeeID = $null

# Metadata: Everyone (Students, Professors, Associates, HR, Secretary):
        $FirstName         = $UserFirstName
        $LastName          = $UserLastName
        $DisplayName       = $UserFirstName + " " + $UserLastName
        $UserPrincipalName = $TestUserAccount + "@" + $DomainInfo.DNSRoot    # DNSRoot=massivedynamic.local
        $EmailAddress      = $TestUserAccount + "@" + $DomainInfo.DNSRoot
        $Company           = "Massive Dynamic Campus"
        $Password          = New-RandomPassword

# Metadata: Students:
        IF ($Title -eq "Student")
        {
            $HomeDir      = "\\FILESERVER01\Students\$TestUserAccount"
            $EmployeeID   = $UserAccountLoopCount
            $HomeDrive    = "H:"

            $Department   = $University
            $UniversityOU = "OU=$University,OU=University"
            $UserOUPath   = "$UserOU,$UniversityOU,$($DomainInfo.DistinguishedName)"
        }

# Metadata: Professors:
        IF ($Title -eq "Professor")
        {
            $HomeDir      = "\\FILESERVER01\Professors\$TestUserAccount"
            $HomeDrive    = "H:"

            $Department   = $University
            $UniversityOU = "OU=$University,OU=University"
            $UserOUPath   = "$UserOU,$UniversityOU,$($DomainInfo.DistinguishedName)"
        }

# Metadata: Associates, HR, Secretary:
        IF ($Title -eq "Associate" -or $Title -eq "HR" -or $Title -eq "Secretary")
        {
            $Department   = $University
            $UniversityOU = "OU=$University,OU=University"
            $UserOUPath   = "$UserOU,$UniversityOU,$($DomainInfo.DistinguishedName)"
        }

        New-ADUser -Name              "$TestUserAccount" `
                   -GivenName         $FirstName `
                   -Surname           $LastName `
                   -SamAccountName    "$TestUserAccount" `
                   -Path              "$UserOUPath" `
                   -AccountPassword   (ConvertTo-SecureString -AsPlainText $Password -Force) `
                   -HomeDirectory     "$HomeDir" `
                   -HomeDrive         "$HomeDrive" `
                   -Company           $Company `
                   -EmailAddress      $EmailAddress `
                   -Department        $Department `
                   -CannotChangePassword $True `
                   -EmployeeID        $EmployeeID `
                   -UserPrincipalName $UserPrincipalName `
                   -Title             $Title `
                   -Enabled           $True `
                   -Server            $DomainDC

        $UserAccountLoopCount++

    } While ($UserAccountLoopCount -le $NumberOfUsers)

    Write-Host "Account creation complete" -ForegroundColor Cyan
}



<#
6. Users

FirstNameFile and LastNameFile are CSV files with a single column that contains 1000 first names and 100 last names respectively. The script randomly selects from these lists to create user accounts with realistic names.
If you use different files in the future with different numbers of entries, adjust $FirstRandom and $LastRandom

This is the plan:
Each university will have same layout for simplicity.
850 students, 25 professors, 15 Associates, 5 HR, 5 Secretary accounts (users).
Total 900 user accounts per faculty x 4 faculties = 3600 users.


Home Folders:
Students and Professors will have home folder on FILESERVER01, while others wont.

H:  -> \\FILESERVER01\Students\jsmith

On FILESERVER01:

D:\Shares
│
├── Students
│   ├── jsmith
│   ├── sjohnson
│   ├── mbrown
│   └── ...
│
├── Students
│   ├── jclark
│   └── ...
|
|
├── Civil
├── Electrical
├── Mechanical
└── Architecture

$HomeDirectory = "\\FILESERVER01\Students\$TestUserAccount"

$HomeDirectory = "\\FILESERVER01\Professors\$TestUserAccount"

Access:
jsmith          Full Control (maybe just read and write)
Administrators  Full Control
SYSTEM          Full Control

File Shares:

Students, Professors (Associates), HR, Secretary will use departmental shares.
Associated will use the same share as Professors, with the same permissions.

\\FILESERVER01\Civil
\\FILESERVER01\Electrical
\\FILESERVER01\Mechanical
\\FILESERVER01\Architecture

Metadata:

Everyone (Students, Professors, Associates, HR, Secretary):

FirstName="John"
LastName="Smith"
DisplayName="John Smith"
UserPrincipalName="jsmith@massivedynamic.local"
EmailAddress="jsmith@massivedynamic.local"
Department="Civil Engineering"
Title="Student" (or Professor, Associate, HR, Secretary)
Company="Massive Dynamic Campus"



User specific metadata:

    Students:

    EmployeeID="0001"
    HomeDirectory="\\FILESERVER01\Students\jsmith"
    HomeDrive="H:"


    Professors:
    HomeDirectory="\\FILESERVER01\Professors\jsmith"
    HomeDrive="H:"



    Associates, HR, Secretary:













#>

# Provide input parameters:
# $Domain = "massivedynamic.local"
# $NumberOfADUserAccounts = ?
# $FirstNameFile = "C:\path\to\first_names.txt"
# $LastNameFile = "C:\path\to\last_names.txt"
# $NameFormatLayout = "FLast"

# $Title = "Student" (Professor, Associate, HR, Secretary) - based on Title input parameter, main separation is made
# and other most important atributes and metadata are assigned based on that.


