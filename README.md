# Automated Azure Policy Remediation

An example of using Event Grid to Trigger a Policy remediation workflow implemented with logic app

<div align="center">
  <img src="https://github.com/ptsouk/Automated-Azure-Policy-Remediation/blob/main/readmeFiles/Automated-Azure-Policy-Remediation.gif?raw=true"
  width="600" height="300"/>
</div>

## Deploy with PowerShell

The required resources and configuration for the implementation are deployed with a bicep template.

```New-AzResourceGroupDeployment -Name 'deploymentName' -ResourceGroupName 'resourceGroupName' -TemplateFile .\main.bicep -DeploymentDebugLogLevel All -Verbose```

## Resources

<div align="center">
  <img src="https://github.com/ptsouk/Automated-Azure-Policy-Remediation/blob/main/readmeFiles/topic.png?raw=true"
  width="600" height="500"/>
</div>

<div align="center">
  <img src="https://github.com/ptsouk/Automated-Azure-Policy-Remediation/blob/main/readmeFiles/remefiation-activity.png?raw=true"
  width="600" height="600"/>
</div>

## Reference

[Reacting to Azure Policy state change events](https://learn.microsoft.com/en-us/azure/governance/policy/concepts/event-overview?tabs=event-grid-event-schema)
