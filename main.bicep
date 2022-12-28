param location string = resourceGroup().location
param workflowResourceNamePrefix string = 'PolicyRemediationWorkflow'
param systemTopicResourceNamePrefix string = 'EventGridPolicyTopic'
param eventSubscriptionResourceNamePrefix string = 'triggerWebhook'
param managementGroupId string = tenant().tenantId
param policyDefinitionIds array = [
  '/providers/microsoft.management/managementgroups/${managementGroupId}/providers/microsoft.authorization/policydefinitions/deploy_nsg_rule'
] // provide a list of policy definitions to include in the event subscription filters
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
    endpointUrl: listCallbackURL('${resourceId('Microsoft.Logic/workflows/', workflowResourceName)}/triggers/manual', '2019-05-01').value
    policyDefinitionIds: policyDefinitionIds
  }
}
