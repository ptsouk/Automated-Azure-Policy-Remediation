param workflowResourceName string
param location string
@secure()
param triggerSecret string

resource workflowResource 'Microsoft.Logic/workflows@2019-05-01' = {
  name: workflowResourceName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    state: 'Enabled'
    definition: {
      '$schema': 'https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#'
      contentVersion: '1.0.0.0'
      parameters: {
      }
      triggers: {
        manual: {
          type: 'Request'
          kind: 'Http'
          inputs: {
            schema: {
              items: {
                properties: {
                  data: {
                    properties: {
                      complianceReasonCode: {
                        type: 'string'
                      }
                      complianceState: {
                        type: 'string'
                      }
                      policyAssignmentId: {
                        type: 'string'
                      }
                      policyDefinitionId: {
                        type: 'string'
                      }
                      policyDefinitionReferenceId: {
                        type: 'string'
                      }
                      subscriptionId: {
                        type: 'string'
                      }
                      timestamp: {
                        type: 'string'
                      }
                    }
                    type: 'object'
                  }
                  dataVersion: {
                    type: 'string'
                  }
                  eventTime: {
                    type: 'string'
                  }
                  eventType: {
                    type: 'string'
                  }
                  id: {
                    type: 'string'
                  }
                  metadataVersion: {
                    type: 'string'
                  }
                  subject: {
                    type: 'string'
                  }
                  topic: {
                    type: 'string'
                  }
                }
                required: [
                  'topic'
                  'id'
                  'eventType'
                  'subject'
                  'data'
                  'dataVersion'
                  'metadataVersion'
                  'eventTime'
                ]
                type: 'object'
              }
              type: 'array'
            }
          }
          conditions: [
            {
              expression: '@equals(triggerOutputs()?[\'headers\']?[\'triggerSecret\'], \'${triggerSecret}\')'
            }
          ]
          operationOptions: 'EnableSchemaValidation'
        }
      }
      actions: {
        For_each: {
          foreach: '@body(\'Parse_JSON\')'
          actions: {
            Condition: {
              actions: {
                HTTP: {
                  runAfter: {
                  }
                  type: 'Http'
                  inputs: {
                    authentication: {
                      audience: environment().resourceManager
                      type: 'ManagedServiceIdentity'
                    }
                    body: {
                      properties: {
                        policyAssignmentId: '@items(\'For_each\')?[\'data\']?[\'policyAssignmentId\']'
                      }
                    }
                    method: 'PUT'
                    uri: '${environment().resourceManager}@{items(\'For_each\')[\'subject\']}/providers/Microsoft.PolicyInsights/remediations/@{guid()}?api-version=2021-10-01'
                  }
                }
              }
              runAfter: {
              }
              expression: {
                and: [
                  {
                    equals: [
                      '@items(\'For_each\')[\'eventType\']'
                      'Microsoft.PolicyInsights.PolicyStateChanged'
                    ]
                  }
                  {
                    equals: [
                      '@items(\'For_each\')?[\'data\']?[\'complianceState\']'
                      'NonCompliant'
                    ]
                  }
                ]
              }
              type: 'If'
            }
          }
          runAfter: {
            Parse_JSON: [
              'Succeeded'
            ]
          }
          type: 'Foreach'
        }
        Parse_JSON: {
          runAfter: {
          }
          type: 'ParseJson'
          inputs: {
            content: '@triggerBody()'
            schema: {
              items: {
                properties: {
                  data: {
                    properties: {
                      complianceReasonCode: {
                        type: 'string'
                      }
                      complianceState: {
                        type: 'string'
                      }
                      policyAssignmentId: {
                        type: 'string'
                      }
                      policyDefinitionId: {
                        type: 'string'
                      }
                      policyDefinitionReferenceId: {
                        type: 'string'
                      }
                      subscriptionId: {
                        type: 'string'
                      }
                      timestamp: {
                        type: 'string'
                      }
                    }
                    type: 'object'
                  }
                  dataVersion: {
                    type: 'string'
                  }
                  eventTime: {
                    type: 'string'
                  }
                  eventType: {
                    type: 'string'
                  }
                  id: {
                    type: 'string'
                  }
                  metadataVersion: {
                    type: 'string'
                  }
                  subject: {
                    type: 'string'
                  }
                  topic: {
                    type: 'string'
                  }
                }
                required: [
                  'topic'
                  'id'
                  'eventType'
                  'subject'
                  'data'
                  'dataVersion'
                  'metadataVersion'
                  'eventTime'
                ]
                type: 'object'
              }
              type: 'array'
            }
          }
        }
      }
      outputs: {
      }
    }
    parameters: {
    }
  }
}

output workflowIdentity string = workflowResource.identity.principalId
output workflowTriggerUrl string = listCallbackURL('${workflowResource.id}/triggers/manual', workflowResource.apiVersion).value
