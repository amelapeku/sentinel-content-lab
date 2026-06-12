// Detects the classic "many failures then a success" pattern from the same
// source IP — likely successful credential brute-force or password spray.
// Uses SecurityEvent (4625 = failed logon, 4624 = successful logon).
param workspace string

@description('Unique id for the scheduled alert rule')
@minLength(1)
param analytic_id string = 'c3d4e5f6-3333-4444-5555-cccccccccccc'

resource workspace_Microsoft_SecurityInsights_analytic_id 'Microsoft.OperationalInsights/workspaces/providers/alertRules@2022-11-01' = {
  name: '${workspace}/Microsoft.SecurityInsights/${analytic_id}'
  kind: 'Scheduled'
  location: resourceGroup().location
  properties: {
    displayName: '[TTT Lab] Failed logons followed by success from same IP'
    description: 'A source IP generated many failed Windows logons (4625) and then a successful logon (4624) for any account within the same hour. Likely successful credential guessing.'
    severity: 'High'
    enabled: false
    query: '''
let FailureThreshold = 10;
let LookbackPeriod = 1h;
let Failures =
    SecurityEvent
    | where TimeGenerated > ago(LookbackPeriod)
    | where EventID == 4625
    | summarize FailureCount = count(), FailedAccounts = make_set(TargetUserName, 20) by IpAddress
    | where FailureCount >= FailureThreshold;
let Successes =
    SecurityEvent
    | where TimeGenerated > ago(LookbackPeriod)
    | where EventID == 4624
    | where LogonType in (2,3,10) // interactive, network, remote interactive
    | project SuccessTime = TimeGenerated, IpAddress, SuccessAccount = TargetUserName, Computer;
Failures
| join kind=inner Successes on IpAddress
| project SuccessTime, IpAddress, SuccessAccount, Computer, FailureCount, FailedAccounts
| extend AccountCustomEntity = SuccessAccount, IPCustomEntity = IpAddress, HostCustomEntity = Computer
'''
    queryFrequency: 'PT1H'
    queryPeriod: 'PT1H'
    triggerOperator: 'GreaterThan'
    triggerThreshold: 0
    suppressionDuration: 'PT1H'
    suppressionEnabled: false
    tactics: [
      'CredentialAccess'
      'InitialAccess'
    ]
    techniques: [
      'T1110'
    ]
    entityMappings: [
      {
        entityType: 'Account'
        fieldMappings: [
          {
            identifier: 'Name'
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
      {
        entityType: 'Host'
        fieldMappings: [
          {
            identifier: 'HostName'
            columnName: 'HostCustomEntity'
          }
        ]
      }
    ]
  }
}
