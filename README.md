# The CyberNova Identity Migration: Microsoft Entra ID (SC-300) Implementation

## 📌 Project Overview
This repository documents a comprehensive identity migration and governance deployment based on "The CyberNova Identity Migration.docx" scenario. The objective was to provision a simulated workforce, enforce Zero Trust access controls, integrate external applications, and automate identity governance.

*   **Organization:** CyberNova
*   **Target Tenant:** Izreal909.onmicrosoft.com
*   **User Base:** 200+ employees across Engineering, Sales, Operations, and IT/Security
*   **Core Technologies:** Microsoft Entra ID, PowerShell, Microsoft Graph API, Conditional Access, Privileged Identity Management (PIM)

---

## 🛠️ Phase 1: Implement and Manage User Identities
**Objective:** Provision the organization, configure the tenant, and automate group memberships.

*   **Bulk User Provisioning:** Developed and executed `Import-EntraUsers.ps1` utilizing the `Microsoft.Graph` module to ingest employee data from a CSV file[cite: 1]. The script authenticated via `Connect-MgGraph`, dynamically mapped users to the `Izreal909.onmicrosoft.com` domain, and assigned temporary passwords (`CyberNova123!`) with a forced reset upon first sign-in.
*   **Delegated Administration:** Created an Administrative Unit (AU) named `AU-Sales-Department`. Assigned the User Administrator role scoped exclusively to this AU to regional IT managers, adhering to the principle of least privilege.
*   **Automated Group Memberships:** Configured Dynamic User Security Groups to map employees automatically based on their departmental attributes (`SG-Engineering`, `SG-Sales`, `SG-Operations`, `SG-IT-Security`).

![mockaroo data csv](Screenshots/mockaroo-data.png)

![powershell-script](Screenshots/powershell-script.png)

![csv-data](Screenshots/csv-data.png)

![script-execution](Screenshots/script-execution.png) 

![add-AU-Sales-Department](Screenshots/add-AU-Sales-Department.png)

![add-users-au](Screenshots/add-users-au.png)

![config-security-groups](Screenshots/config-security-groups.png) 

![add-dynamic-rules](Screenshots/add-dynamic-rules.png)

![add-dynamic-rules2](Screenshots/add-dynamic-rules2.png)

![all-groups-added](Screenshots/all-groups-added.png)




---

## 🔒 Phase 2: Authentication and Access Management
**Objective:** Enforce secure access, deploy MFA, and apply Conditional Access.

*   **Self-Service Password Reset (SSPR):** Enabled tenant-wide SSPR, requiring at least one authentication method (Mobile App or Email) and enforcing registration upon the next user sign-in.
*   **Conditional Access Deployment:**
    *   **Baseline MFA:** Enforced Multifactor Authentication for all users accessing all cloud apps, excluding emergency "break-glass" accounts.
    *   **Identity Protection:** Blocked access for the `SG-IT-Security` group if Entra ID detected High or Medium sign-in risk, requiring them to authenticate from compliant devices or trusted locations.
    *   **Trusted Locations:** Defined specific home/office IP ranges as Named Locations to bypass MFA prompts safely when users are on secure networks.

 ![enable-sspr](Screenshots/enable-sspr.png)
 
 ![mfa-ca](Screenshots/mfa-ca.png)

 ![mfa-ca2](Screenshots/mfa-ca2.png)

 ![it-ca](Screenshots/it-ca.png)

 ![it-ca2](Screenshots/it-ca2.png)

 ![name-locations-ca](Screenshots/name-locations-ca.png)

 ![password-reset](Screenshots/password-reset.png)

 ![mfa-setup](Screenshots/mfa-setup.png)

 ![password-registry](Screenshots/password-registry.png)

 
 



---

## ⚙️ Phase 3: Workload Identities & App Integration
**Objective:** Integrate applications and manage how identities interact with workloads.

*   **SaaS Application Registration:** Registered an Enterprise Application named `CyberNova Engineering Portal`. Granted delegated `User.Read.All` API permissions with tenant-wide admin consent.
*   **Access Restriction:** Enforced assignment requirements on the portal and restricted access exclusively to the `SG-Engineering` dynamic group.
*   **Managed Identities:** Deployed a User-Assigned Managed Identity (`MI-CyberNova-Automation`) and granted it "Reader" Role-Based Access Control (RBAC) over a resource group to securely authorize workload automation without relying on static credentials.

![app-registration](Screenshots/app-registration.png)

![grant-admin](Screenshots/grant-admin.png)

![enterprise-apps](Screenshots/enterprise-apps.png)

![assignment-required](Screenshots/assignment-required.png)

![add-users](Screenshots/add-users.png)

![add-groups](Screenshots/add-groups.png)

![managed-identities](Screenshots/managed-identities.png)

![managed-identities2](Screenshots/managed-identities.png)

![logic-apps](Screenshots/logic-apps.png)

![user-identities](Screenshots/user-identities.png)

![identity](Screenshots/identity.png)


---

## 🛡️ Phase 4: Identity Governance Automation
**Objective:** Enforce least privilege, manage lifecycles, and audit access.

*   **Entitlement Management:** Designed an Access Package named `Sales Onboarding Kit` containing the `SG-Sales` group and relevant Enterprise Applications[cite: 1]. Configured approval workflows requiring sign-off from Sales Managers and established a 180-day access lifecycle expiration.
*   **Privileged Identity Management (PIM):** Secured the User Administrator role by requiring MFA on activation, enforcing business justification, and capping Just-In-Time (JIT) activation durations to 4 hours. Assigned IT Support Admins as eligible candidates rather than permanently active admins.
*   **Automated Access Reviews:** Configured recurring access reviews targeting the `SG-IT-Security` group. Configured the system to automatically revoke access ("Remove access") if the designated manager fails to respond, mitigating the risk of stale administrative accounts.

*[Insert Screenshot: PIM Activation Flow or Access Review Dashboard]*

---
**Author:** Elijah Howard 
**Certifications:** SC-300, CompTIA Security+, CySA+, CSAP, Network+
