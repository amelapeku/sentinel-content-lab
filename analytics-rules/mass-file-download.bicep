// Detects users downloading an unusually high number of files from SharePoint/OneDrive
// in a short window — classic data-staging-before-exfiltration pattern.
param workspace string

@description('Unique id for the scheduled alert rule')
@minLength(1)
param analytic_id string = 'a1b2c3d4-1111-2222-3333-aaaaaaaaaaaa'

resource workspace_Microsoft_SecurityInsights_analytic_id 'Microsoft.OperationalInsights/workspaces/providers/alertRules@2022-11-01' = {
  name: '${workspace}/Microsoft.SecurityInsights/${analytic_id}'
  kind: 'Scheduled'
  location: resourceGroup().location
  properties: {
    displayName: '[TTT Lab] Mass file download from SharePoint or OneDrive'
    description: 'A single user downloaded an unusually large number of files from SharePoint or OneDrive in a short period. Possible data staging before exfiltration.'
    severity: 'Medium'
    enabled: false
    query: '''
let DownloadThreshold = 50;
let LookbackPeriod = 1h;
OfficeActivity
| where TimeGenerated > ago(LookbackPeriod)
| where OfficeWorkload in ('SharePoint','OneDrive')
| where Operation in ('FileDownloaded','FileSyncDownloadedFull')
| summarize
    DownloadCount = count(),
    UniqueFiles = dcount(SourceFileName),
    StartTime = min(TimeGenerated),
    EndTime = max(TimeGenerated),
    FileSample = make_set(SourceFileName, 10)
    by UserId, ClientIP, UserAgent
| where DownloadCount >= DownloadThreshold
| extend AccountCustomEntity = UserId, IPCustomEntity = ClientIP
'''
    queryFrequency: 'PT1H'
    queryPeriod: 'PT1H'
    triggerOperator: 'GreaterThan'
    triggerThreshold: 0
    suppressionDuration: 'PT1H'
    suppressionEnabled: false
    tactics: [
      'Exfiltration'
      'Collection'
    ]
    techniques: [
      'T1530'
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
