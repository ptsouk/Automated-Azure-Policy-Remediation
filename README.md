# Automated-Azure-Policy-Remediation
An example of using Event Grid to Trigger a Policy remediation workflow

## Deploy with PowerShell:
New-AzResourceGroupDeployment -Name deployment name -ResourceGroupName ResourceGroupName -TemplateFile .\main.bicep -DeploymentDebugLogLevel "All" -Verbose
