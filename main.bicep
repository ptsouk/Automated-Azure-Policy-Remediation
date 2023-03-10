param location string = resourceGroup().location
param workflowResourceNamePrefix string = 'PolicyRemediationWorkflow01'
param systemTopicResourceNamePrefix string = 'EventGridPolicyTopic01'
param eventSubscriptionResourceNamePrefix string = 'triggerWebhook'
param managementGroupId string = 'a6e09f1d-1f05-497b-b499-da099ced752f'
param policyDefinitionIds array = [
  '/providers/microsoft.management/managementgroups/${managementGroupId}/providers/microsoft.authorization/policydefinitions/deploy_nsg_rule'
  '/providers/Microsoft.Management/managementGroups/${managementGroupId}/providers/Microsoft.Authorization/policyDefinitions/24f807db-7447-44a6-8fe2-600385b2752d'
]
@secure()
param triggerSecret string = newGuid() // generate a string to include in the post headers and used as condition in the webhook.

var suffix = substring(uniqueString(resourceGroup().id), 0, 4)
var workflowResourceName = '${workflowResourceNamePrefix}-${suffix}'
var systemTopicResourceName = '${systemTopicResourceNamePrefix}-${suffix}'
var eventSubscriptionResourceName = '${eventSubscriptionResourceNamePrefix}-${suffix}'
var role = {
  'Resource Policy Contributor': '/providers/Microsoft.Authorization/roleDefinitions/36243c78-bf99-498c-9df9-86d9f8d28608'
}

module workflow 'modules/workflowResource.bicep' = {
  name: 'workflow-${workflowResourceName}-deployment'
  params: {
    location: location
    workflowResourceName: workflowResourceName
    triggerSecret: triggerSecret
  }
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(subscription().id, workflow.name, role['Resource Policy Contributor'])
  scope: tenant()
  properties: {
    principalId: workflow.outputs.workflowIdentity
    principalType: 'ServicePrincipal'
    roleDefinitionId: role['Resource Policy Contributor']
  }
}

module systemTopic 'modules/systemTopicResource.bicep' = {
  name: 'systemTopic-${systemTopicResourceName}-deployment'
  params: {
    systemTopicResourceName: systemTopicResourceName
    managementGroupId: managementGroupId
    eventSubscriptionResourceName: eventSubscriptionResourceName
    triggerSecret: triggerSecret
    endpointUrl: workflow.outputs.workflowTriggerUrl
    policyDefinitionIds: policyDefinitionIds
  }
}
