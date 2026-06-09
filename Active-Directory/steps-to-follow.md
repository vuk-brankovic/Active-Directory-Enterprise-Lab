The topology of the Active Directory is given in [architecture-topology](../Active-Directory/architecture-topology.md), read that first to get the initial picture. 
Bellow are given follow through steps in order. You can follow them one by one in order to configure complete Active Directory from this project.

Creations and configurations will be done on DC01 inside domain Administrator powershell session until the point when the admin's user account is created. From there we will log in as admin on windows 11 VM and continue creations and configurations in PS from there.

#### OU Structure

Open PS as administrator on DC01 and execute [OU_creation.ps1](../PS-scripts/OU_creation.ps1) script.


```
PS C:\WINDOWS\system32> whoami
massivedynamic\administrator
PS C:\WINDOWS\system32> cd c:\users\Administrator\documents
PS C:\users\Administrator\documents> ls

    Directory: C:\users\Administrator\documents


Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
-a----          6/6/2026   8:20 PM           5175 OU_creation.ps1

PS C:\users\Administrator\documents> .\OU_creation.ps1
```
You can check the results with:
`PS C:\users\Administrator\documents> Get-ADOrganizationalUnit -Filter * | Select-Object Name, DistinguishedName | Sort-Object DistinguishedName`


#### Security Groups

I decided to add OUs and make the Groups more granular.

```
Groups
├── Civil Engineering
├── Electrical Engineering
├── Mechanical Engineering
├── Architecture
├── IT Department
└── Campus Wide
```

```
PS C:\WINDOWS\system32> $groupsPath = "OU=Groups,OU=University,DC=massivedynamic,DC=local"
PS C:\WINDOWS\system32> New-ADOrganizationalUnit -Name "Civil Engineering"    -Path $groupsPath -ProtectedFromAccidentalDeletion $true
PS C:\WINDOWS\system32> New-ADOrganizationalUnit -Name "Electrical Engineering"    -Path $groupsPath -ProtectedFromAccidentalDeletion $true
PS C:\WINDOWS\system32> New-ADOrganizationalUnit -Name "Mechanical Engineering"    -Path $groupsPath -ProtectedFromAccidentalDeletion $true
PS C:\WINDOWS\system32> New-ADOrganizationalUnit -Name "Architecture"    -Path $groupsPath -ProtectedFromAccidentalDeletion $true
PS C:\WINDOWS\system32> New-ADOrganizationalUnit -Name "IT Department"    -Path $groupsPath -ProtectedFromAccidentalDeletion $true
PS C:\WINDOWS\system32> New-ADOrganizationalUnit -Name "Campus Wide"    -Path $groupsPath -ProtectedFromAccidentalDeletion $true
```

Open PS as administrator on DC01 and execute [Groups_creation.ps1](../PS-scripts/Groups_creation.ps1) script.

`PS C:\users\administrator\documents> .\groups_creation.ps1`

You can check the results by playing with: (or open ADUC)

`PS C:\users\administrator\documents> Get-ADGroupMember -Identity "GG_ALL_EMPLOYEES" | Select-Object Name`

![ADUC-security-groups](../general-steps//images_ignore/scr14.PNG)

#### Admin Accounts

1. Create odunham
2. Create pbishop
3. Create wbishop

4. Add them to:
   GG_IT_SYSADMINS

5. Create:
   adm-odunham
   adm-pbishop
   adm-wbishop

6. Add them to:
   GG_IT_SYSADMINS

7. Add only:
   adm-wbishop
   → Domain Admins

8. Log off Administrator
9. Log on as adm-wbishop
10. Continue the project
For the other two, wait until the Delegation phase.

```
PS C:\WINDOWS\system32> $password1 = read-host -AsSecureString
*************
PS C:\WINDOWS\system32> $password2 = read-host -AsSecureString
****************
PS C:\WINDOWS\system32> $password3 = read-host -AsSecureString
*************
```
Passwords are:
Supersecure15, Banana15Columbia, Monkey739Exit
Note: Satisfy the default AD password requirements or accounts will be disabled.

Create user accounts:
```
$sysAdminsPath = "OU=SysAdmins,OU=Users,OU=IT Department,OU=University,DC=massivedynamic,DC=local"

New-ADUser -Name "Olivia Dunham" `
           -SamAccountName "odunham" `
           -UserPrincipalName "odunham@massivedynamic.local" `
           -Path $sysAdminsPath `
           -AccountPassword $password1 `
           -Enabled $true

New-ADUser -Name "Peter Bishop" `
           -SamAccountName "pbishop" `
           -UserPrincipalName "pbishop@massivedynamic.local" `
           -Path $sysAdminsPath `
           -AccountPassword $password2 `
           -Enabled $true

New-ADUser -Name "Walter Bishop" `
           -SamAccountName "wbishop" `
           -UserPrincipalName "wbishop@massivedynamic.local" `
           -Path $sysAdminsPath `
           -AccountPassword $password3 `
           -Enabled $true
```

Add them to GG_IT_SYSADMINS group:
```
Add-ADGroupMember -Identity "GG_IT_SYSADMINS" -Members "odunham","pbishop","wbishop"
```

Create admin accounts:

```
PS C:\WINDOWS\system32> $password4 = read-host -AsSecureString
*********
PS C:\WINDOWS\system32> $password5 = read-host -AsSecureString
********************
PS C:\WINDOWS\system32> $password6 = read-host -AsSecureString
********************
```
Passwords are:
Password1, Donotreusepasswords1, Donotreusepasswords2
Set something from rockyou.txt on adm-wbishop so that you can crack it with hydra later.

```
$adminAccountsPath = "OU=Admin Accounts,OU=University,DC=massivedynamic,DC=local"

New-ADUser -Name "adm-odunham" `
           -SamAccountName "adm-odunham" `
           -UserPrincipalName "adm-odunham@massivedynamic.local" `
           -Path $adminAccountsPath `
           -AccountPassword $password6 `
           -Enabled $true

New-ADUser -Name "adm-pbishop" `
           -SamAccountName "adm-pbishop" `
           -UserPrincipalName "adm-pbishop@massivedynamic.local" `
           -Path $adminAccountsPath `
           -AccountPassword $password5 `
           -Enabled $true

New-ADUser -Name "adm-wbishop" `
           -SamAccountName "adm-wbishop" `
           -UserPrincipalName "adm-wbishop@massivedynamic.local" `
           -Path $adminAccountsPath `
           -AccountPassword $password4 `
           -Enabled $true
```

Add them to their security Groups:

```
PS C:\WINDOWS\system32> Add-ADGroupMember -Identity "GG_IT_SYSADMINS" -Members "adm-odunham","adm-pbishop","adm-wbishop"
PS C:\WINDOWS\system32> Add-ADGroupMember -Identity "Domain Admins" -Members "adm-wbishop"
```

Optionally check the results:

```
PS C:\WINDOWS\system32> Get-ADUser -Filter * -SearchBase "OU=University,DC=massivedynamic,DC=local" | Select-Object Name, SamAccountName, Enabled | Sort-Object Name

Name          SamAccountName Enabled
----          -------------- -------
adm-odunham   adm-odunham       True
adm-pbishop   adm-pbishop       True
adm-wbishop   adm-wbishop       True
Olivia Dunham odunham           True
Peter Bishop  pbishop           True
Walter Bishop wbishop           True


PS C:\WINDOWS\system32> Get-ADGroupMember -Identity "GG_IT_SYSADMINS" | Select-Object Name

Name
----
Olivia Dunham
Peter Bishop
Walter Bishop
adm-odunham
adm-pbishop
adm-wbishop


PS C:\WINDOWS\system32> Get-ADGroupMember -Identity "Domain Admins" | Select-Object Name

Name
----
Administrator
adm-wbishop
```

Leave the DC01 VM running, and start Windows11 Administrator VM, log in as adm-wbishop. (Password1)

```
PS C:\WINDOWS\system32> whoami
massivedynamic\adm-wbishop
PS C:\WINDOWS\system32> net user adm-wbishop /domain
The request will be processed at a domain controller for domain massivedynamic.local.

User name                    adm-wbishop
...SNIP...
Local Group Memberships
Global Group memberships     *GG_IT_SYSADMINS      *Domain Admins
                             *Domain Users
The command completed successfully.
```

#### Service Accounts

Download Active Directory module since it does not come by default on Windows 11 host.
`PS C:\WINDOWS\system32> Add-WindowsCapability -Online -Name Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0`

Create GG_SERVICE_ACCOUNTS:
```
PS C:\WINDOWS\system32> New-ADGroup -Name "GG_SERVICE_ACCOUNTS" -GroupScope Global -GroupCategory Security -Path "OU=IT Department,OU=Groups,OU=University,DC=massivedynamic,DC=local" -Description "All service accounts"
```

Create service accounts:
```
PS C:\WINDOWS\system32> $password1 = Read-Host -AsSecureString
********************
PS C:\WINDOWS\system32> $password2 = Read-Host -AsSecureString
********************
PS C:\WINDOWS\system32> $password3 = Read-Host -AsSecureString
********************
```
Passwords are:
Donotreusepasswords3, Donotreusepasswords4, Donotreusepasswords5


```
$svcPath = "OU=Service Accounts,OU=University,DC=massivedynamic,DC=local"

New-ADUser -Name "svc-splunk" `
           -SamAccountName "svc-splunk" `
           -UserPrincipalName "svc-splunk@massivedynamic.local" `
           -Description "Splunk service account" `
           -Path $svcPath `
           -AccountPassword $password1 `
           -Enabled $true `
           -PasswordNeverExpires $true `
           -CannotChangePassword $true

New-ADUser -Name "svc-backup" `
           -SamAccountName "svc-backup" `
           -UserPrincipalName "svc-backup@massivedynamic.local" `
           -Description "Scheduled backup tasks service account" `
           -Path $svcPath `
           -AccountPassword $password2 `
           -Enabled $true `
           -PasswordNeverExpires $true `
           -CannotChangePassword $true

New-ADUser -Name "svc-ftp" `
           -SamAccountName "svc-ftp" `
           -UserPrincipalName "svc-ftp@massivedynamic.local" `
           -Description "FTP service account" `
           -Path $svcPath `
           -AccountPassword $password3 `
           -Enabled $true `
           -PasswordNeverExpires $true `
           -CannotChangePassword $true
```

Add accounts to GG_SERVICE_ACCOUNTS:

`PS C:\WINDOWS\system32> Add-ADGroupMember -Identity "GG_SERVICE_ACCOUNTS" -Members "svc-splunk","svc-backup","svc-ftp"`

Optionally check results:
`Get-ADGroupMember -Identity "GG_SERVICE_ACCOUNTS" | Select-Object Name`


#### Users

Transfer .csv files on Windows 11 VM -> i used Virtual Box's shared folder for convenience.

Open PS as administrator on Windows11 Administrator and execute [Users_creation.ps1](../PS-scripts/Users_creation.ps1) script.

First and Last name files are in [Files](../Files/FirstNames.csv).
First and Last name files are in [Files](../Files/LastNames.csv).

```
PS C:\users\adm-wbishop\Documents> set-executionPolicy bypass -scope currentUser
PS C:\users\adm-wbishop\Documents> . .\Users_creation.ps1
PS C:\users\adm-wbishop\Documents> Create-ADLabUsers -Domain "massivedynamic.local" -NumberOfADUserAccounts 3400 -FirstNameFile "FirstNames.csv" -LastNameFile "LastNames.csv" -Title "Student" -NameFormatLayout "FLast"
PS C:\users\adm-wbishop\documents> Create-ADLabUsers -Domain "massivedynamic.local" -NumberOfADUserAccounts 100 -FirstNameFile "FirstNames.csv" -LastNameFile "LastNames.csv" -Title "Professor" -NameFormatLayout "FLast"
PS C:\users\adm-wbishop\documents> Create-ADLabUsers -Domain "massivedynamic.local" -NumberOfADUserAccounts 60 -FirstNameFile "FirstNames.csv" -LastNameFile "LastNames.csv" -Title "Associate" -NameFormatLayout "FLast"
PS C:\users\adm-wbishop\documents> Create-ADLabUsers -Domain "massivedynamic.local" -NumberOfADUserAccounts 20 -FirstNameFile "FirstNames.csv" -LastNameFile "LastNames.csv" -Title "HR" -NameFormatLayout "FLast"
PS C:\users\adm-wbishop\documents> Create-ADLabUsers -Domain "massivedynamic.local" -NumberOfADUserAccounts 20 -FirstNameFile "FirstNames.csv" -LastNameFile "LastNames.csv" -Title "Secretary" -NameFormatLayout "FLast"
```

Use [Users_delete.ps1](../PS-scripts/Users_delete.ps1) script if you want to delete users with the same role (Student, Professor, etc.).





