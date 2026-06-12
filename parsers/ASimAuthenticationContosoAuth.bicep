// ASim variant — same parser without parameters. Materialized form used by
// downstream rules that don't pass filter arguments.
param workspace string

resource workspace_ASimAuthenticationContosoAuth 'Microsoft.OperationalInsights/workspaces/savedSearches@2020-08-01' = {
  name: '${workspace}/ASimAuthenticationContosoAuth'
  location: resourceGroup().location
  properties: {
    etag: '*'
    displayName: 'ASIM Authentication parser for ContosoAuth (ASim variant)'
    category: 'Security'
    functionAlias: 'ASimAuthenticationContosoAuth'
    functionParameters: 'disabled:bool=False'
    version: 2
    query: '''
let parser = (disabled:bool=False) {
    ContosoAuth_CL
    | where not(disabled)
    | extend
        EventCount = int(1),
        EventStartTime = TimeGenerated,
        EventEndTime = TimeGenerated,
        EventType = "Logon",
        EventResult = iff(result_s =~ "success", "Success", "Failure"),
        EventOriginalResultDetails = result_s,
        EventSchema = "Authentication",
        EventSchemaVersion = "0.1.3",
        EventVendor = "Contoso",
        EventProduct = "ContosoAuth",
        EventProductVersion = "1.0",
        Dvc = "ContosoAuthService",
        TargetUsername = user_s,
        TargetUsernameType = "UPN",
        SrcIpAddr = src_ip_s,
        TargetAppName = app_s,
        LogonMethod = method_s
    | project-away *_s
};
parser(disabled=disabled)
'''
  }
}
