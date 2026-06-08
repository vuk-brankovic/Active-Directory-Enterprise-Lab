# Active Directory Enterprise Lab

**Status:** In progress - VMs provisioned, core AD infrastructure done, monitoring and attack simulation still being worked on.

A home lab simulating a university Active Directory environment, built from scratch in VirtualBox. Covers domain design, OU structure, security groups, user provisioning, tiered administration, service accounts, GPOs, file shares, etc. Splunk/Sysmon monitoring and basic attack simulation are included on top.

This lab also reflects my University of Belgrade campus. It does take the same starting point universities layout as my [CCNA lab project](https://github.com/vuk-brankovic/three-tier-campus-lan) but it doesn't compare or follow it since that one is limited by Packet Tracer and here we can go a lot wider and more in depth.

---

To read and/or replicate the project lab, start from [general-steps.md](general-steps/general-steps.md) and follow the instructions and links from there.

---

## Environment

| VM | OS | Role |
|---|---|---|
| DC01 | Windows Server 2025 | Domain Controller (massivedynamic.local) |
| ADMIN-PC | Windows 11 | Admin workstation |
| WKS1 | Windows 11 | Standard user workstation |
| SPLUNK-SRV | Ubuntu Server | Splunk SIEM |
| ATTACKER | Parrot Linux | Offensive testing machine |
| SRV01 #TODO | Windows Server 2025 | (File Share, FTP, SQL) |

All machines run in VirtualBox on a shared NAT Network.

---

## What's Been Built

### OU Structure

Hierarchical OU layout for campus: four universities, IT department, and dedicated OUs for servers, service accounts, admin accounts, and disabled objects.

```
massivedynamic.local
└── University
    ├── Civil / Electrical / Mechanical Engineering / Architecture
    │   ├── Users (Students, Professors, Staff, Associates)
    │   └── Computers
    ├── IT Department
    │   ├── Users (Helpdesk, SysAdmins, Security, Management)
    │   └── Computers
    ├── Servers (File, Print, Monitoring, Infrastructure)
    ├── Groups
    ├── Service Accounts
    ├── Admin Accounts
    └── Disabled Objects
```

### Security Groups

Role-based groups following the AGDLP model. Departmental groups nest into campus-wide groups.

```
Campus Wide:  GG_ALL_STUDENTS | GG_ALL_PROFESSORS | GG_ALL_EMPLOYEES | GG_VPN_USERS
IT:           GG_IT_HELPDESK  | GG_IT_SYSADMINS   | GG_IT_SECURITY   | GG_IT_MANAGEMENT → GG_IT_ALL
Per University:     GG_<UNI>_STUDENTS | GG_<UNI>_PROFESSORS | GG_<UNI>_HR | GG_<UNI>_SECRETARY
```

### Tiered Administration

Regular and privileged accounts are separated following standard security practice to limit credential exposure.

- **Tier 1** (`odunham`, `pbishop`, `wbishop`) — daily-use accounts in `OU=SysAdmins`
- **Tier 0** (`adm-odunham`, `adm-pbishop`, `adm-wbishop`) — elevated accounts in `OU=Admin Accounts`
- Only `adm-wbishop` holds Domain Admin rights; the other two are pending delegation

### Service Accounts

Three dedicated service accounts with `PasswordNeverExpires` and `CannotChangePassword` enforced. A fourth (`svc-fileserver`) is planned as a gMSA once the file server is deployed.

| Account | Purpose |
|---|---|
| svc-splunk | Splunk log forwarding |
| svc-backup | Scheduled backup tasks |
| svc-ftp | FTP service |

---

## In Progress

- **GPOs** — workstation hardening, login banners, drive mappings
- **File Shares** — security group-based NTFS permissions
- **Delegation** — scoped AD rights for helpdesk and sysadmin accounts
- **Monitoring & Attack Simulation** — Sysmon + Splunk forwarding on domain machines, followed by basic offensive testing (Hydra, BloodHound, Hashcat) to generate realistic telemetry and practice reading logs

---

## Technologies

- **Active Directory**: OU design, security groups, AGDLP, GPOs, tiered admin, service accounts, delegation, gMSA
- **Windows Server 2025**: Provisioning, DC promotion
- **Ubuntu Server**: Provisioning, Splunk Server configuration
- **Virtualization**: VirtualBox networking, VM cloning, NAT Network segmentation
- **Offensive Security**: Hydra, BloodHound, Hashcat, SecretsDump #TODO
- **SIEM / Monitoring**: Splunk, Sysmon, Windows Event Log analysis #TODO
- **PowerShell**: Complete AD configuration was done using PS commands and scripts. ADUC was mainly used for visual orientation and checking.