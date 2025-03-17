# Terraform


resources:
  pipelines:
  - pipeline: eshoponweb-ci-dockercompose
    source: eshoponweb-ci-dockercompose # given pipeline name
    trigger: true
repositories:
- repository: RELEASE_24_08_DE
    type: git
    name: QRG-ReleaseEngineers/RELEASE_24_08_DE
    ### automatic trigger; uncomment after moving repository to Azure Repos
    # trigger:
    #   branches:
    #     include:
    #     - release/*de*
    #     - release/*uk*

parameters:
- name: ReleaseBranch
  displayName: Release Branch
  type: string
  default: "refs/heads/release/m24.04_jp"
- name: RELEASE_NAME
  displayName: Release Name
  type: string
  default: "MXX.XX_DE"


variables:
  location: 'centralus'
  templateFile: 'infra/aci.bicep'
  subscriptionid: 'YOUR-SUBSCRIPTION-ID'
  azureserviceconnection: 'azure subs'
  webappname: 'az400eshop-NAME'
  acr-login-server: 'YOUR-ACR.azurecr.io'
  acr-username: 'ACR-USERNAME'
  resource-group: 'AZ400-EWebShop-NAME' 


stages:
- stage: Build
  displayName: Docker Compose to ACI
  #variable group referencing KV secret
  variables:
  - group: 'eshopweb-vg'
  jobs:
  - job: Deploy
    pool:
     vmImage: macOS-latest
  #name: "qrg-releaseengineers-lin-ss"
    steps:
  - checkout: RELEASE_24_08_DE

    # Deploy Azure Container Instance using Bicep
    - task: AzureResourceManagerTemplateDeployment@3
      displayName: Deploy ACI Bicep
      inputs:
        deploymentScope: 'Resource Group'
        azureResourceManagerConnection: '$(azureserviceconnection)'
        subscriptionId: '$(subscriptionid)'
        action: 'Create Or Update Resource Group'
        resourceGroupName: '$(resource-group)'
        location: '$(location)'
        templateLocation: 'Linked artifact'
        csmFile: '$(templateFile)'
        overrideParameters: ' -name $(webappname) -image $(acr-login-server)/eshopwebmvc:latest -server $(acr-login-server) -username $(acr-username) -password $(acr-secret)'
        deploymentMode: 'Incremental'
        # deploymentOutputs: 'asp-json'


- stage: Deploy
  displayName: Deploy to an Azure Web App
  jobs:
  - deployment: Deploy
    environment: approvals
    pool:
      vmImage: 'windows-2019'
    strategy:
     runOnce:
      deploy:
       steps:
        - task: DownloadBuildArtifacts@1
          inputs:
           buildType: 'current'
           downloadType: 'single'
           artifactName: 'Website'
           downloadPath: '$(Build.ArtifactStagingDirectory)'

    


![image](https://github.com/user-attachments/assets/17d77db0-a9a3-403a-ab5f-7bd9d3787294)
