# ============================================================
# AD OU Structure - massivedynamic.local
# ============================================================
# New-ADOrganizationalUnit parameters:
# -Name: the display name of the OU
# -Path: the Distinguished Name of the parent container
# -ProtectedFromAccidentalDeletion: prevents accidental deletion
# from GUI, good practice for all OUs
# ============================================================

# --- ROOT UNDER DOMAIN ---
# Everything sits under this single top-level OU
New-ADOrganizationalUnit -Name "University" -Path "DC=massivedynamic,DC=local" -ProtectedFromAccidentalDeletion $true

# --- TOP LEVEL UNDER UNIVERSITY ---
$uniPath = "OU=University,DC=massivedynamic,DC=local"

New-ADOrganizationalUnit -Name "Civil Engineering"        -Path $uniPath -ProtectedFromAccidentalDeletion $true
New-ADOrganizationalUnit -Name "Electrical Engineering"   -Path $uniPath -ProtectedFromAccidentalDeletion $true
New-ADOrganizationalUnit -Name "Mechanical Engineering"   -Path $uniPath -ProtectedFromAccidentalDeletion $true
New-ADOrganizationalUnit -Name "Architecture"             -Path $uniPath -ProtectedFromAccidentalDeletion $true
New-ADOrganizationalUnit -Name "IT Department"            -Path $uniPath -ProtectedFromAccidentalDeletion $true
New-ADOrganizationalUnit -Name "Servers"                  -Path $uniPath -ProtectedFromAccidentalDeletion $true
New-ADOrganizationalUnit -Name "Groups"                   -Path $uniPath -ProtectedFromAccidentalDeletion $true
New-ADOrganizationalUnit -Name "Service Accounts"         -Path $uniPath -ProtectedFromAccidentalDeletion $true
New-ADOrganizationalUnit -Name "Admin Accounts"           -Path $uniPath -ProtectedFromAccidentalDeletion $true
New-ADOrganizationalUnit -Name "Disabled Objects"         -Path $uniPath -ProtectedFromAccidentalDeletion $true

# --- FACULTY OU STRUCTURE (same for all four faculties) ---
# The distinguished name uses comma-separated OU= components read right to left,
# so "OU=Civil Engineering,OU=University,DC=massivedynamic,DC=local" means:
# Civil Engineering inside University inside the domain.

$faculties = @(
    "Civil Engineering",
    "Electrical Engineering",
    "Mechanical Engineering",
    "Architecture"
)

foreach ($faculty in $faculties) {
    $facultyPath = "OU=$faculty,$uniPath"

    # Users and Computers directly under each faculty
    New-ADOrganizationalUnit -Name "Users"     -Path $facultyPath -ProtectedFromAccidentalDeletion $true
    New-ADOrganizationalUnit -Name "Computers" -Path $facultyPath -ProtectedFromAccidentalDeletion $true

    $usersPath = "OU=Users,$facultyPath"

    # Students sits directly under Users
    New-ADOrganizationalUnit -Name "Students"  -Path $usersPath -ProtectedFromAccidentalDeletion $true

    # Employees and its sub-OUs
    New-ADOrganizationalUnit -Name "Employees" -Path $usersPath -ProtectedFromAccidentalDeletion $true

    $employeesPath = "OU=Employees,$usersPath"

    New-ADOrganizationalUnit -Name "Professors"  -Path $employeesPath -ProtectedFromAccidentalDeletion $true
    New-ADOrganizationalUnit -Name "Staff"        -Path $employeesPath -ProtectedFromAccidentalDeletion $true
    New-ADOrganizationalUnit -Name "Associates"   -Path $employeesPath -ProtectedFromAccidentalDeletion $true

    $staffPath = "OU=Staff,$employeesPath"

    New-ADOrganizationalUnit -Name "HR"        -Path $staffPath -ProtectedFromAccidentalDeletion $true
    New-ADOrganizationalUnit -Name "Secretary" -Path $staffPath -ProtectedFromAccidentalDeletion $true
}

# --- IT DEPARTMENT ---
$itPath = "OU=IT Department,$uniPath"

New-ADOrganizationalUnit -Name "Users"     -Path $itPath -ProtectedFromAccidentalDeletion $true
New-ADOrganizationalUnit -Name "Computers" -Path $itPath -ProtectedFromAccidentalDeletion $true

$itUsersPath = "OU=Users,$itPath"

New-ADOrganizationalUnit -Name "Helpdesk"    -Path $itUsersPath -ProtectedFromAccidentalDeletion $true
New-ADOrganizationalUnit -Name "SysAdmins"   -Path $itUsersPath -ProtectedFromAccidentalDeletion $true
New-ADOrganizationalUnit -Name "Security"    -Path $itUsersPath -ProtectedFromAccidentalDeletion $true
New-ADOrganizationalUnit -Name "Management"  -Path $itUsersPath -ProtectedFromAccidentalDeletion $true

# --- SERVERS ---
$serversPath = "OU=Servers,$uniPath"

New-ADOrganizationalUnit -Name "File Servers"        -Path $serversPath -ProtectedFromAccidentalDeletion $true
New-ADOrganizationalUnit -Name "Print Servers"       -Path $serversPath -ProtectedFromAccidentalDeletion $true
New-ADOrganizationalUnit -Name "Monitoring"          -Path $serversPath -ProtectedFromAccidentalDeletion $true
New-ADOrganizationalUnit -Name "Infrastructure"      -Path $serversPath -ProtectedFromAccidentalDeletion $true

# --- Disabled Objects ---
$disabledObjectsPath = "OU=Disabled Objects,$uniPath"

New-ADOrganizationalUnit -Name "Users"        -Path $disabledObjectsPath -ProtectedFromAccidentalDeletion $true
New-ADOrganizationalUnit -Name "Computers"       -Path $disabledObjectsPath -ProtectedFromAccidentalDeletion $true