# ============================================================
# AD Groups Creation - massivedynamic.local
# ============================================================

$basePath = "OU=Groups,OU=University,DC=massivedynamic,DC=local"

# ============================================================
# CAMPUS WIDE GROUPS
# These are created first because faculty groups will be nested inside them.
# MyNote: @ is array ok.
# ============================================================

$campusWidePath = "OU=Campus Wide,$basePath"

$campusWideGroups = @(
    "GG_ALL_STUDENTS",
    "GG_ALL_PROFESSORS",
    "GG_ALL_EMPLOYEES",
    "GG_VPN_USERS"
)

foreach ($group in $campusWideGroups) {
    New-ADGroup -Name $group `
                -GroupScope Global `
                -GroupCategory Security `
                -Path $campusWidePath
}

# ============================================================
# FACULTY GROUPS
# Hashtable maps full faculty OU name to the short prefix used in group names. GetEnumerator() lets us loop through
# key-value pairs — $faculty.Key is the OU name, $faculty. Value is the prefix like CIVIL, ELEC etc.
# MyNote: hashtable is kinda like dictionary in Python, ok. GetEnumerator() is a method for looping key-value pairs in a hashtable, ok.
# ============================================================

$faculties = @{
    "Civil Engineering"      = "CIVIL"
    "Electrical Engineering" = "ELEC"
    "Mechanical Engineering" = "MECH"
    "Architecture"           = "ARCH"
}

foreach ($faculty in $faculties.GetEnumerator()) {
    $facultyPath = "OU=$($faculty.Key),$basePath"
    $prefix = $faculty.Value

    $facultyGroups = @(
        "GG_$($prefix)_STUDENTS",
        "GG_$($prefix)_PROFESSORS",
        "GG_$($prefix)_ASSOCIATES",
        "GG_$($prefix)_HR",
        "GG_$($prefix)_SECRETARY"
    )

    foreach ($group in $facultyGroups) {
        New-ADGroup -Name $group `
                    -GroupScope Global `
                    -GroupCategory Security `
                    -Path $facultyPath
    }
}

# ============================================================
# IT DEPARTMENT GROUPS
# GG_IT_ALL created first so role groups can nest inside it
# ============================================================

$itPath = "OU=IT Department,$basePath"

New-ADGroup -Name "GG_IT_ALL"        -GroupScope Global -GroupCategory Security -Path $itPath
New-ADGroup -Name "GG_IT_HELPDESK"   -GroupScope Global -GroupCategory Security -Path $itPath
New-ADGroup -Name "GG_IT_SYSADMINS"  -GroupScope Global -GroupCategory Security -Path $itPath
New-ADGroup -Name "GG_IT_SECURITY"   -GroupScope Global -GroupCategory Security -Path $itPath
New-ADGroup -Name "GG_IT_MANAGEMENT" -GroupScope Global -GroupCategory Security -Path $itPath

# ============================================================
# GROUP MEMBERSHIPS
# ============================================================

# IT role groups all nest into GG_IT_ALL
Add-ADGroupMember -Identity "GG_IT_ALL" `
                  -Members "GG_IT_HELPDESK","GG_IT_SYSADMINS","GG_IT_SECURITY","GG_IT_MANAGEMENT"

# Faculty groups nest into their campus-wide parents
foreach ($faculty in $faculties.GetEnumerator()) {
    $prefix = $faculty.Value

    # Students belong to GG_ALL_STUDENTS
    Add-ADGroupMember -Identity "GG_ALL_STUDENTS" `
                      -Members "GG_$($prefix)_STUDENTS"

    # Professors belong to both GG_ALL_EMPLOYEES and GG_ALL_PROFESSORS
    Add-ADGroupMember -Identity "GG_ALL_EMPLOYEES"  -Members "GG_$($prefix)_PROFESSORS"
    Add-ADGroupMember -Identity "GG_ALL_PROFESSORS" -Members "GG_$($prefix)_PROFESSORS"

    # Associates, HR, Secretary belong to GG_ALL_EMPLOYEES
    Add-ADGroupMember -Identity "GG_ALL_EMPLOYEES" `
                      -Members "GG_$($prefix)_ASSOCIATES","GG_$($prefix)_HR","GG_$($prefix)_SECRETARY"
}