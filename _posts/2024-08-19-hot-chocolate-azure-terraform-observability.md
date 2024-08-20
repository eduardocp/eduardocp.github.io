---
layout: post
title: Automating Azure Infrastructure for a .NET Project with Terraform, OpenTelemetry, and Observability
date: 2024-08-19 09:00:00
cover-img: /assets/img/covers/2024-08-19-hot-chocolate-azure-terraform-observability.png
thumbnail-img: /assets/img/covers/2024-08-19-hot-chocolate-azure-terraform-observability.png
share-img: /assets/img/covers/2024-08-19-hot-chocolate-azure-terraform-observability.png
gh-repo: eduardocp/eduardocp.github.io
gh-badge: [star, fork, follow]
tags: [graphql, dotnet, hot chocolate, c#, terraform, azure, open telemetry, observability]
comments: true
author: Eduardo Carísio
---

Creating and managing cloud infrastructure can be complex, but tools like Terraform and OpenTelemetry make it easier. In this guide, we'll set up Azure infrastructure for a .NET project using Terraform, integrate Hot Chocolate as the GraphQL engine, and implement observability using Azure Monitor and OpenTelemetry.

## Prerequisites

Before you start, ensure you have the following:

- **Terraform** installed.
- **Azure CLI** installed and authenticated.
- **.NET SDK** installed.
- Basic knowledge of Terraform, Azure, and .NET development.

## Step 1: Define the Azure Infrastructure with Terraform

### 1.1 Create a New ASP.NET Core Project
<span> </span>
```bash
dotnet new webapi -n HotChocolateObservabilityTerraform -controllers
cd HotChocolateObservabilityTerraform
```

### 1.2 Create the Terraform Configuration File

Create a directory for your Terraform files and add a `providers.tf` file with the following content:

```hcl
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
}

provider "azurerm" {
  features {}
}
```

And add a `main.tf` file with the following content:

```hcl
resource "azurerm_resource_group" "rg" {
  name     = "dotnet-hotchocolate-rg"
  location = "West Europe"
}

resource "azurerm_service_plan" "asp" {
  name                = "dotnet-hotchocolate-asp"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"
  sku_name            = "F1"
}

resource "azurerm_linux_web_app" "app" {
  name                = "dotnet-hotchocolate-app"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  service_plan_id     = azurerm_service_plan.asp.id
  al

  site_config {
    always_on = false # Set to false because free tiers can't use always on
    application_stack {
        dotnet_version = "8.0"
    }
  }

  app_settings = {
    "WEBSITE_RUN_FROM_PACKAGE"               = "1"
    "APPINSIGHTS_INSTRUMENTATIONKEY"         = azurerm_application_insights.appinsights.instrumentation_key
    "APPLICATIONINSIGHTS_CONNECTION_STRING"  = azurerm_application_insights.appinsights.connection_string
  }
}

resource "azurerm_application_insights" "appinsights" {
  name                = "dotnet-hotchocolate-appinsights"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  application_type    = "web"
}
```

### 1.3 Initialize and Apply the Configuration

To deploy the infrastructure:

1. Initialize Terraform:

    ```bash
    terraform init
    ```
    <span> </span>
2. Review and apply the changes:

    ```bash
    terraform apply
    ```
    <span> </span>
Terraform will prompt you to confirm the changes. Type `yes` to deploy the infrastructure.

## Step 2: Integrate Hot Chocolate in Your .NET Project

### 2.1 Install Hot Chocolate

Back to the root folder and install Hot Chocolate via NuGet in your .NET project:

```bash
dotnet add package HotChocolate.AspNetCore
```

### 2.2 Configure GraphQL Server

In your `Program.cs` (or `Startup.cs`), configure the GraphQL server:

```csharp
public class Program
{
    public static void Main(string[] args)
    {
        var builder = WebApplication.CreateBuilder(args);

        builder.Services
            .AddGraphQLServer()
            .AddQueryType<Query>();

        var app = builder.Build();

        app.UseRouting();
        app.UseEndpoints(endpoints =>
        {
            endpoints.MapGraphQL();
        });

        app.Run();
    }
}
```

### 2.3 Define a Simple Query

Create a new class to define a GraphQL query:

```csharp
public class Query
{
    public string Hello() => "Hello, world!";
}
```

This sets up a basic GraphQL endpoint at `/graphql` in your application.

## Step 3: Implement Observability with Azure Monitor (Optional)

### 3.1 Add Application Insights to Your Project

Add the Application Insights SDK:

```bash
dotnet add package Microsoft.ApplicationInsights.AspNetCore
```

### 3.2 Configure Application Insights

In `Program.cs` or `Startup.cs`, configure Application Insights:

```csharp
    builder.Services.AddApplicationInsightsTelemetry();
```

### 3.3 Create a Class to Send Custom Metrics

Create a class to send custom telemetry data:

```csharp
using Microsoft.ApplicationInsights;
using Microsoft.ApplicationInsights.DataContracts;

public class CustomTelemetry
{
    private readonly TelemetryClient _telemetryClient;

    public CustomTelemetry(TelemetryClient telemetryClient)
    {
        _telemetryClient = telemetryClient;
    }

    public void TrackCustomEvent(string eventName)
    {
        var telemetry = new EventTelemetry(eventName);
        _telemetryClient.TrackEvent(telemetry);
    }

    public void TrackException(Exception ex)
    {
        _telemetryClient.TrackException(ex);
    }
}
```

## Step 4: Integrate OpenTelemetry with Your .NET Project

### 4.1 Install OpenTelemetry NuGet Packages

Install the necessary OpenTelemetry packages:

```bash
dotnet add package Azure.Monitor.OpenTelemetry.AspNetCore --version 1.3.0-beta.1
dotnet add package HotChocolate.Diagnostics
dotnet add package OpenTelemetry.Instrumentation.AspNetCore
dotnet add package OpenTelemetry.Instrumentation.Http
```

### 4.2 Configure OpenTelemetry

In `Program.cs` or `Startup.cs`, configure OpenTelemetry:

```csharp
using OpenTelemetry.Trace;
using OpenTelemetry.Metrics;
using OpenTelemetry.Logs;
using OpenTelemetry.Resources;
using Azure.Monitor.OpenTelemetry.AspNetCore;

public class Program
{
    public static void Main(string[] args)
    {
        var builder = WebApplication.CreateBuilder(args);

        builder.Services.AddLogging(builder =>
        {
            builder.AddOpenTelemetry(b =>
            {
                b.IncludeFormattedMessage = true; // The default is false to better storage and network traffic performance
                b.IncludeScopes = true; //Include scope 
                b.ParseStateValues = true; // True to avoid access state directly as the docs recommends
                b.SetResourceBuilder(ResourceBuilder.CreateDefault().AddService("DotNetHotChocolateService"));
            });
        });

        builder.Services
            .AddOpenTelemetry()
            .WithTracing(tracerProviderBuilder =>
            {
                tracerProviderBuilder
                    .AddHttpClientInstrumentation()
                    .AddAspNetCoreInstrumentation()
                    .AddEntityFrameworkCoreInstrumentation(); //if you use
                    .AddHotChocolateInstrumentation();
                    .SetResourceBuilder(ResourceBuilder.CreateDefault().AddService("DotNetHotChocolateService"));
            })
            .UseAzureMonitor(options => options.ConnectionString = builder.Configuration["APPLICATIONINSIGHTS_CONNECTION_STRING"]);

        var app = builder.Build();

        app.UseRouting();
        app.UseEndpoints(endpoints =>
        {
            endpoints.MapGraphQL();
        });

        app.Run();
    }
}
```

### 4.3 Update Terraform Configuration

Ensure that your Terraform configuration includes the Application Insights connection string:

```hcl
resource "azurerm_app_service" "app" {
  app_settings = {
    "WEBSITE_RUN_FROM_PACKAGE"               = "1"
    "APPINSIGHTS_INSTRUMENTATIONKEY"         = azurerm_application_insights.appinsights.instrumentation_key
    "APPLICATIONINSIGHTS_CONNECTION_STRING"  = azurerm_application_insights.appinsights.connection_string
  }
}
```

## Conclusion

By following these steps, you've automated the deployment of your Azure infrastructure using Terraform, integrated Hot Chocolate for GraphQL in your .NET project, and set up comprehensive observability with Azure Monitor and OpenTelemetry.

## Code

<a href="https://github.com/eduardocp/HotChocolateObservabilityTerraform" target="_blank">https://github.com/eduardocp/HotChocolateObservabilityTerraform</a>