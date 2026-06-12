// Im (imported / unified) entry point — the function downstream queries call
// to get authentication events across all sources, including ContosoAuth.
param workspace string

resource workspace_Im_AuthenticationCustom 'Microsoft.OperationalInsights/workspaces/savedSearches@2020-08-01' = {
  name: '${workspace}/Im_AuthenticationCustom'
  location: resourceGroup().location
  properties: {
    etag: '*'
    displayName: 'Im_Authentication custom unifier (includes ContosoAuth)'
    category: 'Security'
    functionAlias: 'Im_AuthenticationCustom'
    functionParameters: 'starttime:datetime=datetime(null), endtime:datetime=datetime(null), targetusername_has:string="*", disabled:bool=False'
    version: 2
    query: '''
union isfuzzy=true
    vimAuthenticationContosoAuth(starttime, endtime, targetusername_has, disabled)
    // Add other vim* parsers here as new sources are onboarded, e.g.:
    // , vimAuthenticationAWSCloudTrail(starttime, endtime, targetusername_has, disabled)
'''
  }
}
