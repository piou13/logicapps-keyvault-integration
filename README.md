# LogicApps Keyvault Integration

This article shows a way to use Azure Keyvault integration with Azure LogicApps in order to manage sensitive information but by using Managed Identity (formely Azure MSI) and not the LogicApps KeyVault Connector.

In Azure architectures, dealing with sensitive information, like credentials, secrets or connection strings, often drives to Azure Keyvault.

When an Azure LogicApps workflow needs to consume these sensitive information from Keyvault, the *natural* way to go would be to use the integrated connector ([https://docs.microsoft.com/en-us/connectors/keyvault/](https://docs.microsoft.com/en-us/connectors/keyvault/)). As always, we need to provide an identity for this API Connection but this time we have 2 options: a service account or an Azure Service Principal Name.
![enter image description here](https://github.com/piou13/logicapps-keyvault-integration/blob/master/docs/kv1.PNG)
If you choose 

I like automation