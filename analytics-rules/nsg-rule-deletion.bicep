// Detects NSG security rule deletions via the Azure control plane.
// NSG rule removal is a common attacker action when establishing C2 or
// preparing for data exfiltration.
param workspace string

@description('Unique id for the scheduled alert rule')
@minLength(1)
param analytic_id string = 'b2c3d4e5-2222-3333-4444-bbbbbbbbbbbb'

resource workspace_Microsoft_SecurityInsights_analytic_id 'Microsoft.OperationalInsights/workspaces/providers/alertRules@2022-11-01' = {
  name: '${workspace}/Microsoft.SecurityInsights/${analytic_id}'
  kind: 'Scheduled'
  location: resourceGroup().location
  properties: {
    displayName: '[TTT Lab] NSG security rule deletion'
    description: 'Someone deleted a network security group rule. This is a high-fidelity signal during incidents — attackers remove deny rules to open paths for C2 or exfiltration.'
    severity: 'Medium'
    enabled: false
    query: '''
AzureActivity
| where OperationNameValue =~ 'MICROSOFT.NETWORK/NETWORKSECURITYGROUPS/SECURITYRULES/DELETE'
| where ActivityStatusValue =~ 'Success'
| project
    TimeGenerated,
    Caller,
    CallerIpAddress,
    ResourceGroup,
    Resource,
    SubscriptionId,
    _ResourceId
| extend AccountCustomEntity = Caller, IPCustomEntity = CallerIpAddress
'''
    queryFrequency: 'PT1H'
    queryPeriod: 'PT1H'
    triggerOperator: 'GreaterThan'
    triggerThreshold: 0
    suppressionDuration: 'PT1H'
    suppressionEnabled: false
    tactics: [
      'DefenseEvasion'
      'Impact'
    ]
    techniques: [
      'T1562'
    ]
    entityMappings: [
      {
        entityType: 'Account'
        fieldMappings: [
          {
            identifier: 'FullName'
            columnName: 'AccountCustomEntity'
          }
        ]
      }
      {
        entityType: 'IP'
        fieldMappings: [
          {
            identifier: 'Address'
            columnName: 'IPCustomEntity'
          }
        ]
      }
    ]
  }
}
