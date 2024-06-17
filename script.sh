githubOrganizationName='shahidazim'
githubRepositoryName='toy-website-environments'

applicationRegistrationDetails=$(az ad app create --display-name 'toy-website-environments')
applicationRegistrationObjectId=$(echo $applicationRegistrationDetails | jq -r '.id')
applicationRegistrationAppId=$(echo $applicationRegistrationDetails | jq -r '.appId')

servicePrincipalId=$(az ad sp create --id $applicationRegistrationAppId --query id --output tsv)

subscriptionId=$(az account show --query id --output tsv)

az role assignment create --role Contributor \
   --subscription $subscriptionId \
   --assignee-object-id $servicePrincipalId \
   --assignee-principal-type ServicePrincipal \
   --scope /subscriptions/$subscriptionId

az ad app federated-credential create \
   --id $applicationRegistrationObjectId \
   --parameters "{\"name\":\"toy-website-environments_main\",\"issuer\":\"https://token.actions.githubusercontent.com\",\"subject\":\"repo:${githubOrganizationName}/${githubRepositoryName}:ref:refs/heads/main\",\"description\":\"The federated identity credentials for main branch\",\"audiences\":[\"api://AzureADTokenExchange\"]}"

az ad app federated-credential create \
   --id $applicationRegistrationObjectId \
   --parameters "{\"name\":\"toy-website-environments_pull-request\",\"issuer\":\"https://token.actions.githubusercontent.com\",\"subject\":\"repo:${githubOrganizationName}/${githubRepositoryName}:pull_request\",\"description\":\"The federated identity credentials for pull request\",\"audiences\":[\"api://AzureADTokenExchange\"]}"

az ad app federated-credential create \
   --id $applicationRegistrationObjectId \
   --parameters "{\"name\":\"toy-website-environments_env-production\",\"issuer\":\"https://token.actions.githubusercontent.com\",\"subject\":\"repo:${githubOrganizationName}/${githubRepositoryName}:environment:Production\",\"description\":\"The federated identity credentials for Production environment\",\"audiences\":[\"api://AzureADTokenExchange\"]}"
