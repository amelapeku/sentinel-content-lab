// vim-style ASIM parser for the fictional ContosoAuth product.
// Carried over from the Parsing TTT — single-source-of-truth example for Step 5.
param workspace string

resource workspace_vimAuthenticationContosoAuth 'Microsoft.OperationalInsights/workspaces/savedSearches@2020-08-01' = {
  name: '${workspace}/vimAuthenticationContosoAuth'
  location: resourceGroup().location
  properties: {
    etag: '*'
    displayName: 'ASIM Authentication parser for ContosoAuth (vim variant)'
    category: 'Security'
    functionAlias: 'vimAuthenticationContosoAuth'
    functionParameters: 'starttime:datetime=datetime(null), endtime:datetime=datetime(null), targetusername_has:string="*", disabled:bool=False'
    version: 2
    query: '''
let parser = (starttime:datetime=datetime(null), endtime:datetime=datetime(null), targetusername_has:string="*", disabled:bool=False) {
    ContosoAuth_CL
    | where not(disabled)
    | where (isnull(starttime) or TimeGenerated >= starttime)
    | where (isnull(endtime) or TimeGenerated <= endtime)
    | where (targetusername_has == "*" or user_s has targetusername_has)
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
parser(starttime=starttime, endtime=endtime, targetusername_has=targetusername_has, disabled=disabled)
'''
  }
}
