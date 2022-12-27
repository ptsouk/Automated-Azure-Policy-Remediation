param location string = resourceGroup().location
param keyVaultName string = 'keyvault27122022'
param workflowResourceName string = 'PolicyRemediation-la'
param systemTopicResourceName string = 'EventGridPolicyTopic01'
param managementGroupId string = 'a6e09f1d-1f05-497b-b499-da099ced752f'
param eventSubscriptionResourceName string = 'triggerWebhook'
param policyDefinitionIds array = [
  '/providers/microsoft.management/managementgroups/${managementGroupId}/providers/microsoft.authorization/policydefinitions/deploy_nsg_rule'
]

var uniqueSuffix = substring(uniqueString(resourceGroup().id), 0, 4)
var role = {
  'Resource Policy Contributor': '/providers/Microsoft.Authorization/roleDefinitions/36243c78-bf99-498c-9df9-86d9f8d28608'
}


resource keyVault 'Microsoft.KeyVault/vaults@2021-10-01' existing = {
  name: keyVaultName
  scope: resourceGroup()
}

module workflow 'modules/workflowResource.bicep' = {
  dependsOn: [
    keyVault
  ]
  name: 'workflow-${workflowResourceName}-${uniqueSuffix}-deployment'
  params: {
    location: location
    workflowResourceName: workflowResourceName
    triggerSecret: keyVault.getSecret('triggerSecret')
  }
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(subscription().id, workflow.name, role['Resource Policy Contributor'])
  scope: tenant()
  properties: {
    principalId: workflow.outputs.workflowIdentity
    roleDefinitionId: role['Resource Policy Contributor']
  }
}

module systemTopic 'modules/systemTopicResource.bicep' = {
  dependsOn: [
    workflow
    keyVault
  ]
  name: 'systemTopic-${systemTopicResourceName}-${uniqueSuffix}-deployment'
  params: {
    systemTopicResourceName: systemTopicResourceName
    managementGroupId: managementGroupId
    eventSubscriptionResourceName: eventSubscriptionResourceName
    triggerSecret: keyVault.getSecret('triggerSecret')
    endpointUrl: listCallbackURL('${resourceId('Microsoft.Logic/workflows/', workflowResourceName)}/triggers/manual', '2019-05-01').value
    policyDefinitionIds: policyDefinitionIds
  }
}
