---
layout: post
permalink: /deploy-terraform-github-actions
title: Deploy terraform and HotChocolate with GitHub Actions
date: 2024-08-19 09:00:00
cover-img: /assets/img/covers/2024-08-19-hot-chocolate-azure-terraform-observability.png
thumbnail-img: /assets/img/covers/2024-08-19-hot-chocolate-azure-terraform-observability.png
share-img: /assets/img/covers/2024-08-19-hot-chocolate-azure-terraform-observability.png
gh-repo: eduardocp/eduardocp.github.io
gh-badge: [star, follow]
tags: [graphql, dotnet, hot chocolate, c#, terraform, azure, open telemetry, observability]
comments: true
author: Eduardo Carísio
---

Deploying a .NET project with Terraform in GitHub Actions is an effective way to automate your deployment pipeline. This process can streamline the management of infrastructure and application deployment, ensuring consistency, scalability, and security. Below is a step-by-step guide on how to set up this deployment pipeline.

## Prerequisites
1. **.NET Project**: You should have a .NET project ready to be deployed.
2. **Terraform Configuration**: A Terraform script that defines the infrastructure needed for your project.
3. **GitHub Repository**: The .NET project and Terraform configuration should be stored in a GitHub repository.
4. **Azure Subscription**: Since Terraform will be provisioning resources in Azure, ensure you have an active Azure subscription.
5. **Azure Service Principal**: This will be used to authenticate Terraform in Azure.
6. **GitHub Actions Workflow**: Familiarity with GitHub Actions for creating CI/CD pipelines.

## Step 1: Set Up Terraform Configuration

Terraform configuration files (typically `.tf` files) define the infrastructure resources you want to deploy in Azure. Below is a simple example of a Terraform configuration to deploy an Azure App Service.

```hcl
provider "azurerm" {
  features = {}
}

resource "azurerm_resource_group" "rg" {
  name     = "myResourceGroup"
  location = "East US"
}

resource "azurerm_app_service_plan" "app_service_plan" {
  name                = "myAppServicePlan"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku {
    tier = "Free"
    size = "F1"
  }
}

resource "azurerm_app_service" "app_service" {
  name                = "myAppService"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  app_service_plan_id = azurerm_app_service_plan.app_service_plan.id
}
```

This configuration deploys an Azure App Service in a specified resource group and location.

## Step 2: Create Azure Service Principal

To deploy resources in Azure using Terraform, you need to create a Service Principal with sufficient permissions. This can be done via the Azure CLI.

```bash
az ad sp create-for-rbac --name "terraform-sp" --role Contributor \
   --scopes /subscriptions/{subscription-id} \
   --sdk-auth
```

This command returns a JSON object containing the credentials needed to authenticate Terraform in Azure. Save these credentials securely as they will be used in GitHub Actions.

## Step 3: Store Azure Credentials in GitHub Secrets

Store the service principal credentials in your GitHub repository as secrets. Go to your repository on GitHub and navigate to **Settings > Secrets and variables > Actions**. Add the following secrets:

- `AZURE_CREDENTIALS`: The JSON output from the Service Principal creation step.
- `AZURE_SUBSCRIPTION_ID`: Your Azure subscription ID.
- `AZURE_TENANT_ID`: Your Azure tenant ID.

## Step 4: Set Up GitHub Actions Workflow

Create a `.github/workflows/deploy.yml` file in your repository to define the GitHub Actions workflow. Below is an example workflow that builds the .NET project, deploys it to Azure, and applies the Terraform configuration.

```yaml
name: Deploy to Azure

on:
  push:
    branches:
      - main

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v3
      
    - name: Setup .NET Core
      uses: actions/setup-dotnet@v3
      with:
        dotnet-version: '7.x'

    - name: Restore dependencies
      run: dotnet restore

    - name: Build
      run: dotnet build --configuration Release --no-restore

    - name: Publish
      run: dotnet publish --configuration Release --output ./output

    - name: Upload Artifact
      uses: actions/upload-artifact@v3
      with:
        name: dotnet-app
        path: ./output

  deploy:
    runs-on: ubuntu-latest
    needs: build
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v3
    
    - name: Download Artifact
      uses: actions/download-artifact@v3
      with:
        name: dotnet-app

    - name: Setup Terraform
      uses: hashicorp/setup-terraform@v2

    - name: Azure Login
      uses: azure/login@v1
      with:
        creds: ${{ secrets.AZURE_CREDENTIALS }}

    - name: Initialize Terraform
      run: terraform init

    - name: Apply Terraform
      run: terraform apply -auto-approve

    - name: Deploy to Azure App Service
      uses: azure/webapps-deploy@v2
      with:
        app-name: "myAppService"
        package: ./output
        publish-profile: ${{ secrets.AZURE_WEBAPP_PUBLISH_PROFILE }}
```

## Step 5: Deploy and Monitor

1. **Trigger the Workflow**: Push your changes to the `main` branch to trigger the workflow.
2. **Monitor the Pipeline**: Go to the **Actions** tab in your GitHub repository to monitor the workflow's progress.
3. **Verify the Deployment**: Once the workflow completes, verify that the .NET application is deployed and running in Azure.

## Conclusion

By following these steps, you can successfully deploy a .NET project using Terraform in GitHub Actions. This setup ensures a robust and automated deployment pipeline, leveraging the power of infrastructure as code and continuous deployment.
