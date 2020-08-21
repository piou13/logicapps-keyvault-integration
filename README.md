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
 - The connector is represented by an "API Connection" object (*Microsoft.Web/connections*) that needs to be declared in the ARM template.

All of these burden the automation, development and maintenance process.

## Managed Identities for Azure to the rescue

To simplify the automation process while enforcing robustness and maintenance, I definitely prefer using LogicApps and Keyvault in conjunction with Managed Identities for Azure (formerly Azure MSI).

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

Personally, in most of my scenarios, I configure User-Assigned managed identity because I rarely have only one LogicApps in my solutions. If you have multiple *"Managed Identities for Azure compatible"* services (like LogicApps, FunctionApp, API Management, ...) that need to access quite the same set of resources from Keyvault, definitely use an User-Assigner managed identity.
If you have a small solution with an one-to-one relationship between LogicApps and Keyvault or if you have big dichotomy concerns, choose System-Assigned managed identity.