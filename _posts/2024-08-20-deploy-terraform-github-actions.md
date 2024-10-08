---
layout: post
permalink: /deploy-azure-terraform-github-actions
title: Deploy to Azure with terraform and HotChocolate using GitHub Actions
date: 2024-08-19 09:00:00
cover-img: /assets/img/covers/2024-08-19-hot-chocolate-azure-terraform-observability.png
thumbnail-img: /assets/img/covers/2024-08-19-hot-chocolate-azure-terraform-observability.png
share-img: /assets/img/covers/2024-08-19-hot-chocolate-azure-terraform-observability.png
gh-repo: eduardocp/eduardocp.github.io
gh-badge: [star, follow]
tags: [graphql, dotnet, hot chocolate, c#, terraform, azure, infrastructure, automation]
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

We will use the terraform files generated [here at Step 1](/hot-chocolate-azure-terraform-observability#step-1-define-the-azure-infrastructure-with-terraform)

## Step 2: Create Azure Service Principal

To deploy resources in Azure using Terraform, you need to create a Service Principal with sufficient permissions. This can be done via the Azure CLI.

```bash
az ad sp create-for-rbac --name "terraform-sp" --role Contributor --scopes /subscriptions/{subscription-id} --sdk-auth
```

This command returns a JSON object containing the credentials needed to authenticate Terraform in Azure. Save these credentials securely as they will be used in GitHub Actions.

## Step 3: Store Azure Credentials in GitHub Secrets

## 3.1 Store Azure Credentials in GitHub Secrets

Store the service principal credentials in your GitHub repository as secrets. Go to your repository on GitHub and navigate to **Settings > Secrets and variables > Actions**. Add the following **Repository secrets**:

- `AZURE_CREDENTIALS`: The JSON output from the Service Principal creation step.
- `AZURE_SUBSCRIPTION_ID`: Your Azure subscription ID.
- `AZURE_TENANT_ID`: Your Azure tenant ID.

## 3.1 Configure read/write permission to Workflow

Go to your repository on GitHub and navigate to **Settings > Code and automation > Actions > General**. At the end, on **Workflow permissions** section, check **Read and write permissions**.

## Step 4: Set Up GitHub Actions Workflow

Create a `.github/workflows/deploy.yml` file in your repository to define the GitHub Actions workflow. Below is an example workflow that builds the .NET project, deploys it to Azure, and applies the Terraform configuration.

```yaml
name: Deploy to Azure

on:
  push:
    branches:
      - main

jobs:
  deploy_infra:
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
        with:
          sparse-checkout: azure # Checkout only the azure directory

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3

      - name: Azure Login
        uses: azure/login@v2
        with:
          creds: {% raw %}${{ secrets.AZURE_CREDENTIALS }}{% endraw %}

      - name: Initialize Terraform
        run: terraform init
        working-directory: azure

      - name: Apply Terraform
        run: terraform apply -auto-approve
        working-directory: azure

      - name: Commit state # Save the Terraform state to prevent errors and wrong changes in the future runnings. There are better ways to do this, but this is a simple way to do it.
        run: |
          git config --global user.name '<YourName>'
          git config --global user.email '<YourEmail>'
          git add azure/.terraform.lock.hcl
          git add azure/terraform.tfstate
          git commit -m "🏗️ Automatically Updated Terraform State. [skip ci]"
          git push

      - name: Get Publish Profile # Get the publish profile to deploy the app
        run: |
          echo "PUBLISH_PROFILE=$(az webapp deployment list-publishing-profiles -g 'dotnet-hotchocolate-rg' -n 'dotnet-hotchocolate-app' --xml)" >> $GITHUB_OUTPUT
        id: getPublishProfile

  deploy:
    runs-on: ubuntu-latest
    needs: deploy_infra
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4
      
    - name: Setup .NET Core
      uses: actions/setup-dotnet@v4
      with:
        dotnet-version: '8.x'

    - name: Publish
      run: dotnet publish --configuration Release --property:PublishDir=./output

    - name: Azure Login
      uses: azure/login@v2
      with:
        creds: {% raw %}${{ secrets.AZURE_CREDENTIALS }}{% endraw %}

    - name: Deploy to Azure App Service
      uses: azure/webapps-deploy@v3
      with:
        app-name: "dotnet-hotchocolate-app"
        package: ./output
        publish-profile: {% raw %}${{ steps.getPublishProfile.outputs.PUBLISH_PROFILE }}{% endraw %}
```

Pay attention to `<YourName>` and `<YourEmail>`. Replace with your information.

## Step 5: Deploy and Monitor

1. **Trigger the Workflow**: Push your changes to the `main` branch to trigger the workflow.
2. **Monitor the Pipeline**: Go to the **Actions** tab in your GitHub repository to monitor the workflow's progress.
3. **Verify the Deployment**: Once the workflow completes, verify that the .NET application is deployed and running in Azure.

## Conclusion

By following these steps, you can successfully deploy a .NET project using Terraform in GitHub Actions. This setup ensures a robust and automated deployment pipeline, leveraging the power of infrastructure as code and continuous deployment.

## Code

<a href="https://github.com/eduardocp/HotChocolateObservabilityTerraform" target="_blank">https://github.com/eduardocp/HotChocolateObservabilityTerraform</a>