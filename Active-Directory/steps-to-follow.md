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



