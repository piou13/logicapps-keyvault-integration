# LogicApps Keyvault Integration

This article shows a way to use Azure Keyvault integration with Azure LogicApps in order to manage sensitive information but by using Managed Identities for Azure (formerly Azure MSI) and not the LogicApps KeyVault Connector.


## Overall considerations

In Azure architectures, dealing with sensitive information, like credentials, secrets or connection strings, often drives to Azure Keyvault.

When an Azure LogicApps workflow needs to consume these sensitive information from Keyvault, the "natural" way to go would be to use the integrated connector ([https://docs.microsoft.com/en-us/connectors/keyvault/](https://docs.microsoft.com/en-us/connectors/keyvault/)). For sure, we need to provide an identity for this API Connection but this time we have 2 options: a service account or an Azure Service Principal Name.

![enter image description here](https://github.com/piou13/logicapps-keyvault-integration/blob/master/docs/kv1.PNG)

If you choose connector method, obviously, I would recommend to use the Azure SPN.
However, I don't like this method... Why?

I like automation and provisioning, especially when it comes to deploy and configure many Azure artifacts and Services and even for Microsoft 365, MS Teams, SharePoint. In most cases here, the simpler the better.

But what's the caveat with the Keyvault Connector? (particularly from an automation perspective)
Long story short: 

 - Using a service account is not reliable (in my opinion)
 - Using a SPN is good but mostly required the creation and configuration of a dedicated Azure App Registration (to be included in the provisioning script)
 - Azure App Registration secrets may expire! like a password for a service account (regarding some companies policies). You need to manage the life cycle.
 - The connector is represented by an "API Connection" object (*Microsoft.Web/connections*) that needs to be declared in the ARM template. Moreover, API Connections require, in some cases, manual steps after deployment.

All of these burden the automation, development and maintenance process.


## Managed Identities for Azure to the rescue (MIA)

To simplify the automation process while enforcing robustness and maintenance, I definitely prefer using LogicApps and Keyvault in conjunction with MIA - Managed Identities for Azure (formerly Azure MSI).

More information here: [https://docs.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/overview](https://docs.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/overview)

This is a definition from Microsoft:

> "Internally, managed identities are service principals of a special
> type, which are locked to only be used with Azure resources. When the
> managed identity is deleted, the corresponding service principal is
> automatically removed. Also, when a User-Assigned or System-Assigned
> Identity is created, the Managed Identity Resource Provider (MSRP)
> issues a certificate internally to that identity.
> 
> Your code can use a managed identity to request access tokens for services that support Azure AD authentication. Azure takes care of rolling the credentials that are used by the service instance."

Now, we can better understand why it simplifies the development, maintenance and overall life cycle.

On the Automation part, the benefit here is that there's nothing to take care at the Azure AD level, everything happen at the ARM template level. So, no more Azure App Registration as a prerequisite.

In LogicApps, Managed Identities are managed by browsing the *Identity* section:

![enter image description here](https://github.com/piou13/logicapps-keyvault-integration/blob/master/docs/kv2.PNG)

**System-Assigned or User-Assigned?**

Personally, in most of my scenarios, I configure User-Assigned managed identity because I rarely have only one LogicApps in my solutions. If you have multiple *"MIA-compatible"* services (like LogicApps, FunctionApp, API Management, ...) that need to access quite the same set of resources from Keyvault, definitely use an User-Assigned managed identity.
If you have a small solution with an one-to-one relationship between LogicApps and Keyvault or if you have big dichotomy concerns, choose System-Assigned managed identity.


## High level architecture

This diagram shows a simple representation of what is implemented in this sample (but only for one LogicApps). You can iterate and use the same User-Assigned managed identity from different LogicApps.

![enter image description here](https://github.com/piou13/logicapps-keyvault-integration/blob/master/docs/kv6.png)


## Configuration in Azure portal

**User-Assigned managed identity**

In the portal, search for *'Managed Identities'* and create or manage identities.
![enter image description here](https://github.com/piou13/logicapps-keyvault-integration/blob/master/docs/kv7.PNG)

**LogicApps integration**

In the *'Identity'* section, click the *'User-Assigned'* tab and add the previously created identity.
![enter image description here](https://github.com/piou13/logicapps-keyvault-integration/blob/master/docs/kv8.PNG)

**LogicApps action**

In the LogicApps *'HTTP action',* define the target endpoint and the authentication parameters. You should see your User-Assigned managed identity as a choice.
![enter image description here](https://github.com/piou13/logicapps-keyvault-integration/blob/master/docs/kv9.PNG)

**KeyVault Access Policies**

In the *'Access Policies'* for the KeyVault, grant permissions for the User-Assigned managed identity.
![enter image description here](https://github.com/piou13/logicapps-keyvault-integration/blob/master/docs/kv10.PNG)


## What's needed for automation then?

Minimally, we need these 3 Azure resources declared in the ARM template:

 1. User-Assigned managed identity
 2. Keyvault + Secret
 3. LogicApps

We don't need to create any SPN at the Azure AD level because it's actually managed under the hood by the User-Assigned managed identity.

Here's some interesting points from the template:

 - Setting the KeyVault Access Policy by getting dynamically the reference to the deployed User-Assigned managed identity.
![enter image description here](https://github.com/piou13/logicapps-keyvault-integration/blob/master/docs/kv3.PNG)
 - Setting the identity configuration for the LogicApps to use the User-Assigned managed identity. The schema is a bit strange here because you need to set dynamically a node name but not a node value.
![enter image description here](https://github.com/piou13/logicapps-keyvault-integration/blob/master/docs/kv4.PNG)


That's it to start playing with information stored in KeyVault from multiple LogicApps.
Of course, I recommend to put additional security feature like Secure Input and Secure Output when needed:
![enter image description here](https://github.com/piou13/logicapps-keyvault-integration/blob/master/docs/kv5.PNG)


## Install the sample

**Prerequisites:** 

 - An Azure subscription
 - Contributor on the targeted Azure Resources Group

**The sample contains:**

 - The setup script
 - The ARM template

**Installation:**
Run the setup.ps1 script with the following parameters:

 - ResourceGroupName: *The name of an existing Azure Resources Group.*
 - KeyvaultName: *The KeyVault's name (a secret named MySecretName with value MySecretValue will be created.*
 - LogicappsName: *The LogicApps' name.*
 - UserAssignedIdentitiesName: *The name of the Azure User-Assigned managed identity.*

setup.ps1 -ResourceGroupName <your_value> -KeyvaultName <your_value> -LogicappsName <your_value> -UserAssignedIdentitiesName <your_value>

    