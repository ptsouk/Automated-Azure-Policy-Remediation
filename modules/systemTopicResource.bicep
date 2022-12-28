param systemTopicResourceName string
param managementGroupId string
param eventSubscriptionResourceName string
@secure()
param triggerSecret string
@secure()
param endpointUrl string
param policyDefinitionIds array

resource systemTopicsResource 'Microsoft.EventGrid/systemTopics@2022-06-15' = {
  name: systemTopicResourceName
  location: 'global'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    source: '/tenants/${tenant().tenantId}/providers/Microsoft.Management/managementGroups/${managementGroupId}'
    topicType: 'Microsoft.PolicyInsights.PolicyStates'
  }
}

resource eventSubscriptionResource 'Microsoft.EventGrid/systemTopics/eventSubscriptions@2022-06-15' = {
  parent: systemTopicsResource
  name: eventSubscriptionResourceName
  properties: {
    destination: {
      properties: {
        maxEventsPerBatch: 1
        preferredBatchSizeInKilobytes: 64
        deliveryAttributeMappings: [
          {
            properties: {
              sourceField: 'subject'
            }
            name: 'subject'
            type: 'Dynamic'
          }
          {
            properties: {
              sourceField: 'id'
            }
            name: 'id'
            type: 'Dynamic'
          }
          {
            properties: {
              sourceField: 'topic'
            }
            name: 'topic'
            type: 'Dynamic'
          }
          {
            properties: {
              sourceField: 'eventtype'
            }
            name: 'eventtype'
            type: 'Dynamic'
          }
          {
            properties: {
              sourceField: 'dataversion'
            }
            name: 'dataversion'
            type: 'Dynamic'
          }
          {
            properties: {
              value: triggerSecret
              isSecret: true
            }
            name: 'triggerSecret'
            type: 'Static'
          }
        ]
        endpointUrl: endpointUrl
      }
      endpointType: 'WebHook'
    }
    filter: {
      includedEventTypes: [
        'Microsoft.PolicyInsights.PolicyStateChanged'
      ]
      enableAdvancedFilteringOnArrays: true
      advancedFilters: [
        {
          values: policyDefinitionIds
          operatorType: 'StringIn'
          key: 'data.policyDefinitionId'
        }
        {
          values: [
            'NonCompliant'
          ]
          operatorType: 'StringContains'
          key: 'data.complianceState'
        }
      ]
    }
    labels: []
    eventDeliverySchema: 'EventGridSchema'
    retryPolicy: {
      maxDeliveryAttempts: 30
      eventTimeToLiveInMinutes: 1440
    }
  }
}
