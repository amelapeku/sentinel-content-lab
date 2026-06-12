// Placeholder workbook so the first deployment in Step 3 has something to deploy.
// Swap `serializedData` with the JSON from your real workbook (e.g. the
// Defender vs AMA coverage workbook) once you've validated the pipeline.
//
// `workspace` is auto-injected by the Sentinel deployment pipeline — it's the
// workspace *name*. We resolve it to a full resource ID for `sourceId`.
param workspace string

@description('Unique GUID for this workbook. Keep stable across deployments to update in place.')
param workbookId string = '7e8a4b32-1111-4d2c-9aaa-aaaaaaaaaaaa'

resource workbook 'Microsoft.Insights/workbooks@2022-04-01' = {
  name: workbookId
  location: resourceGroup().location
  kind: 'shared'
  properties: {
    displayName: '[TTT Lab] Placeholder — replace me'
    category: 'sentinel'
    sourceId: resourceId('Microsoft.OperationalInsights/workspaces', workspace)
    version: '1.0'
    serializedData: '''
{
    "version": "Notebook/1.0",
    "items": [
        {
            "type": 1,
            "content": {
                "json": "# TTT Lab placeholder workbook\n\nIf you can see this in Sentinel → Workbooks, the pipeline works.\n\nReplace `serializedData` in `workbooks/placeholder.bicep` with the JSON of your real workbook to update it."
            },
            "name": "intro",
            "id": "bd843576-0725-484e-9167-75e97901a5e0"
        },
        {
            "type": 3,
            "content": {
                "version": "KqlItem/1.0",
                "query": "Heartbeat\n| summarize LastSeen = max(TimeGenerated) by Computer\n| top 25 by LastSeen desc",
                "size": 0,
                "title": "Recent agent heartbeats",
                "queryType": 0,
                "resourceType": "microsoft.operationalinsights/workspaces",
                "crossComponentResources": [
                    "/subscriptions/fe70d943-14c9-4c71-9451-7429c8c7b390/resourcegroups/general-fr/providers/microsoft.operationalinsights/workspaces/law-france"
                ]
            },
            "name": "heartbeats",
            "id": "acbefd91-d9b4-4f6b-9325-e2cad071eeb4"
        }
    ],
    "fallbackResourceIds": [
        "/subscriptions/fe70d943-14c9-4c71-9451-7429c8c7b390/resourcegroups/general-fr/providers/microsoft.operationalinsights/workspaces/law-france"
    ],
    "$schema": "https://github.com/Microsoft/Application-Insights-Workbooks/blob/master/schema/workbook.json",
    "context": {
        "ownerId": "/subscriptions/fe70d943-14c9-4c71-9451-7429c8c7b390/resourcegroups/general-fr/providers/microsoft.operationalinsights/workspaces/law-france"
    }
}