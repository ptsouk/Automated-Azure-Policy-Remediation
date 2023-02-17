# Automated-Azure-Policy-Remediation

An example of using Event Grid to Trigger a Policy remediation workflow implemented with logic app

<div align="center">
  <img src="https://github.com/ptsouk/Automated-Azure-Policy-Remediation/blob/main/readmeFiles/Automated-Azure-Policy-Remediation.gif?raw=true" width="600" height="300"/>
</div>

## Deploy with PowerShell

New-AzResourceGroupDeployment -Name deploymentName -ResourceGroupName resourceGroupName -TemplateFile .\main.bicep -DeploymentDebugLogLevel "All" -Verbose
