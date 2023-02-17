# Automated Azure Policy Remediation

An example of using Event Grid to Trigger a Policy remediation workflow implemented with logic app

<div align="center">
  <img src="https://github.com/ptsouk/Automated-Azure-Policy-Remediation/blob/main/readmeFiles/Automated-Azure-Policy-Remediation.gif?raw=true"
  width="600" height="300"/>
</div>

## Deploy with PowerShell

The required resources and configuration for the implementation is included in the bicep template.

```New-AzResourceGroupDeployment -Name deploymentName -ResourceGroupName resourceGroupName -TemplateFile .\main.bicep -DeploymentDebugLogLevel "All" -Verbose```

## Reference

[Reacting to Azure Policy state change events](https://learn.microsoft.com/en-us/azure/governance/policy/concepts/event-overview?tabs=event-grid-event-schema)
