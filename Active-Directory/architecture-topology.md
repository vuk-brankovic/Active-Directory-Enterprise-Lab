#### Mental Picture and Execution Plan:
1. Domain Creation (Done)
2. OU Structure
3. Groups
4. Admin Accounts
After admin user adm-sysadmin01 is created continue AD configuration logged as admin.
5. Service Accounts
6. Users
7. Computers
8. GPOs
9. File Shares
10. Delegation
11. Monitoring



##### 2. OU Structure:

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
    │   ├── Domain Controllers
    │   ├── File Servers
    │   ├── Print Servers
    │   ├── Monitoring
    │   └── Infrastructure
    │
    ├── Groups
    │    ├── 
    │    ├── 
    │    ├── 
    │    ├── 
    │
    ├── Service Accounts
    │    ├── svc-splunk
    │    ├── svc-backup
    │    ├── svc-ftp
    │    ├── svc-monitoring
    │
    └── Admin Accounts
        ├── adm-jsmith
        ├── adm-helpdesk01
        ├── adm-sysadmin01









































