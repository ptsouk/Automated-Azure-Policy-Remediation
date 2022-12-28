# Automated-Azure-Policy-Remediation

An example of using Event Grid to Trigger a Policy remediation workflow implemented with logic app

## Deploy with PowerShell

New-AzResourceGroupDeployment -Name deploymentName -ResourceGroupName resourceGroupName -TemplateFile .\main.bicep -DeploymentDebugLogLevel "All" -Verbose
