#### Mental Picture and Execution Plan:
1. Domain Creation (Done)
2. OU Structure
3. Groups
4. Admin Accounts
After admin user (adm-wbishop) is created continue AD configuration logged as admin.
5. Service Accounts
6. Users
7. Computers
8. GPOs
9. File Shares
10. Delegation
11. Monitoring



##### 2. OU Structure:

```
massivedynamic.local

└── University
    ├── Civil Engineering
    │   ├── Users
    │   │   ├── Students
    │   │   └── Employees
    │   │       ├── Professors
    │   │       ├── Staff
    │   │       │   ├── HR
    │   │       │   └── Secretary
    │   │       └── Associates
    │   └── Computers
    │
    ├── Electrical Engineering (same as Civil Eng.)
    ├── Mechanical Engineering (same as Civil Eng.)
    ├── Architecture (same as Civil Eng.)
    │
    ├── IT Department
    │   ├── Users
    │   │   ├── Helpdesk
    │   │   ├── SysAdmins
    │   │   ├── Security
    │   │   └── Management
    │   └── Computers
    │
    ├── Servers
    │   ├── File Servers
    │   ├── Print Servers
    │   ├── Monitoring
    │   └── Infrastructure
    │
    ├── Groups
    │    ├── .
    │    ├── .
    │    ├── .
    │    ├── .
    │
    ├── Service Accounts
    │    ├── svc-splunk
    │    ├── svc-backup
    │    ├── svc-ftp
    │    ├── svc-monitoring
    │
    └── Admin Accounts
    │    ├── *adm-jsmith
    │    ├── *adm-helpdesk01
    │    ├── *adm-sysadmin01
    │
    ├── Disabled Objects
    │    ├── Users
    │    ├── Computers
```

See the configuration steps in [steps-to-follow](../Active-Directory/steps-to-follow.md#ou-structure)


##### 3. Groups

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

Identity groups:

```
Groups
├── Civil Engineering
GG_CIVIL_STUDENTS (member of: GG_ALL_STUDENTS, )
GG_CIVIL_PROFESSORS (member of: GG_ALL_EMPLOYEES, GG_ALL_PROFESSORS)
GG_CIVIL_ASSOCIATES (member of: GG_ALL_EMPLOYEES )
GG_CIVIL_HR (member of: GG_ALL_EMPLOYEES )
GG_CIVIL_SECRETARY (member of: GG_ALL_EMPLOYEES )
├── Electrical Engineering
SAME AS CIVIL
├── Mechanical Engineering
SAME AS CIVIL
├── Architecture
SAME AS CIVIL
├── IT Department
GG_IT_HELPDESK (member of: GG_IT_ALL)
GG_IT_SYSADMINS (member of: GG_IT_ALL)
GG_IT_SECURITY (member of: GG_IT_ALL)
GG_IT_MANAGEMENT (member of: GG_IT_ALL)
GG_IT_ALL
└── Campus Wide
GG_ALL_STUDENTS
GG_ALL_PROFESSORS
GG_ALL_EMPLOYEES
GG_VPN_USERS

```

File shares security groups will be made later in a step 9.
See the configuration steps in [steps-to-follow](../Active-Directory/steps-to-follow.md#security-groups)

##### 4. Admin Accounts

Admin user will have two accounts. One for daily use: wbishop, and one for highly administrative tasks: adm-wbishop.

```
IT Department
└── Users
    ├── Helpdesk
    ├── SysAdmins
    │   ├── odunham
    │   ├── pbishop
    │   └── wbishop
    ├── Security
    └── Management
```
```
Admin Accounts
├── adm-odunham
├── adm-pbishop
└── adm-wbishop
```

Accounts under SysAdmins OU (ex. odunham) will be normal regular user accounts.
Accounts under Admin Accounts OU (ex. adm-odunham) will be granted various special rights.
Highest account will be adm-wbishop which will be granted Domain Admin rights. We will use this account to continue configuration of the AD.

See the configuration steps in [steps-to-follow](../Active-Directory/steps-to-follow.md#admin-accounts)

##### 5. Service Accounts

```
Service Accounts
├── svc-backup
├── svc-splunk
├── svc-ftp
```

Add group GG_SERVICE_ACCOUNTS under OU=Groups,OU=IT Department.
Add all three service accounts to that group.

Service Accounts should have:
Password never expires = Enabled
User cannot change password = Enabled

svc-fileserver was ommited from here and will be configured to use gMSA once the fileserver computer is created and joined.

See the configuration in [steps-to-follow](../Active-Directory/steps-to-follow.md#service-accounts).












