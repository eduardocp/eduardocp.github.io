---
layout: post
title: Integrating Hot Chocolate and Fluent Validation
date: 2024-08-13 21:00:00
cover-img: https://camo.githubusercontent.com/1232fcfc89c329dad97528011ffe5d29ab825009eca3f96fc1c063ee5babb2dd/68747470733a2f2f6368696c6c69637265616d2e636f6d2f7265736f75726365732f6368696c6c69637265616d2d6772617068716c2d62616e6e65722e737667
thumbnail-img: https://api.nuget.org/v3-flatcontainer/hotchocolate/13.9.11/icon
share-img: https://api.nuget.org/v3-flatcontainer/hotchocolate/13.9.11/icon
gh-repo: eduardocp/eduardocp.github.io
gh-badge: [star, fork, follow]
tags: [graphql, dotnet, hot chocolate, c#, fluent validation]
comments: true
author: Eduardo Carísio
---

## Introduction

Hot Chocolate is a powerful .NET GraphQL server library that simplifies the creation of GraphQL APIs. Fluent Validation is a popular library for building strongly-typed validation rules in .NET applications. Combining these tools allows you to create robust and well-validated GraphQL APIs with a clean and maintainable codebase. This article will guide you through setting up and using Hot Chocolate with Fluent Validation in a C# application.

## Prerequisites

- Basic understanding of GraphQL and C#.
- Familiarity with ASP.NET Core.
- .NET SDK installed on your machine.

## Setting Up the Project

### 1. Create a New ASP.NET Core Project

Start by creating a new ASP.NET Core project. You can do this using the .NET CLI:

```bash
dotnet new webapi -n HotChocolateFluentValidation -controllers
cd HotChocolateFluentValidation
```

### 2. Install Required Packages

Add the necessary NuGet packages for Hot Chocolate and Fluent Validation:

```bash
dotnet add package HotChocolate.AspNetCore
dotnet add package AppAny.HotChocolate.FluentValidation
```

These packages include Hot Chocolate for GraphQL, Fluent Validation for validation, and the integration package for using Fluent Validation with Hot Chocolate.

## Setting Up Hot Chocolate

### 1. Configure Hot Chocolate

In the `Startup.cs` or `Program.cs` file (depending on .NET version), configure Hot Chocolate:

```csharp
using Microsoft.AspNetCore.Builder;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using HotChocolate.AspNetCore;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddGraphQLServer()
    .AddQueryType<Query>()
    .AddMutationType<Mutation>();

var app = builder.Build();

// Configure the HTTP request pipeline.
app.UseRouting();
app.UseEndpoints(endpoints =>
{
    endpoints.MapGraphQL();
});

app.Run();
```

In this example, we configure Hot Chocolate to use the `Query` and `Mutation` types.

### 2. Define GraphQL Types

Create a GraphQL query type in `Query.cs`:

```csharp
public class Query
{
    public string HelloWorld => "Hello, world!";
}
```

### 3. Configure GraphQL Server

Ensure that the GraphQL server is properly configured to handle requests. This is usually handled in `Program.cs` with the `AddGraphQLServer` method.

## Setting Up Fluent Validation

### 1. Create a Validation Class

Define a validator for your GraphQL input types. For example, create a file named `UserInputValidator.cs`:

```csharp
using FluentValidation;

public class UserInput
{
    public string Name { get; set; }
    public int Age { get; set; }
}

public class UserInputValidator : AbstractValidator<UserInput>
{
    public UserInputValidator()
    {
        RuleFor(x => x.Name).NotEmpty().WithMessage("Name is required.");
        RuleFor(x => x.Age).GreaterThan(0).WithMessage("Age must be greater than zero.");
    }
}
```

### 2. Register the validator

Register Fluent Validation in your `Startup.cs` or `Program.cs`:

```csharp
builder.Services.AddScoped<UserInputValidator>();
```

### 3. Integrate Fluent Validation with Hot Chocolate

Integrate Fluent Validation with Hot Chocolate by adding the `AddFluentValidation` method to the GraphQL configuration:

```csharp
using AppAny.HotChocolate.FluentValidation;

builder.Services.AddGraphQLServer()
    .AddQueryType<Query>()
    .AddMutationType<Mutation>()
    .AddFluentValidation(o => o.UseDefaultErrorMapper());
```

## Implementing GraphQL Mutations with Validation

### 1. Define a Mutation Type

Create a `Mutation.cs` file to define a mutation:

```csharp
public class Mutation
{
    public async Task<string> CreateUserAsync([UseFluentValidation, UseValidator<UserInputValidator>] UserInput input, [Service] IUserService userService)
    {
        // Add user creation logic here
        return await userService.CreateUserAsync(input);
    }
}
```

### 2. Implement the User Service

Define a user service for handling user creation logic:

```csharp
public interface IUserService
{
    Task<string> CreateUserAsync(UserInput input);
}

public class UserService : IUserService
{
    public Task<string> CreateUserAsync(UserInput input)
    {
        // Logic for creating a user
        return Task.FromResult("User created successfully.");
    }
}
```

### 3. Register the User Service

Register your user service in the dependency injection container:

```csharp
builder.Services.AddScoped<IUserService, UserService>();
```

## Testing the Integration

### 1. Run the Application

Run your application using the .NET CLI:

```bash
dotnet run
```

### 2. Access GraphQL Playground

Open your browser and navigate to `http://localhost:5000/graphql` (or the appropriate port) to access the GraphQL Playground.

### 3. Test Queries and Mutations

You can test your GraphQL queries and mutations using the Playground. For example:

```graphql
mutation {
  createUser(input: { name: "John Doe", age: 30 })
}
```

### 4. Validate Input

Test invalid inputs to ensure that Fluent Validation is correctly intercepting and handling validation errors.

## Conclusion

Integrating Hot Chocolate with Fluent Validation in a C# application allows you to build robust and validated GraphQL APIs. By following the steps outlined in this guide, you can set up a GraphQL server, define validation rules, and ensure that your API inputs are correctly validated before processing.

This integration not only helps in maintaining data integrity but also ensures a better developer experience by leveraging strong typing and clear validation rules.

Feel free to adjust the configuration and code examples based on your application's specific needs. Happy coding!

## Code

<a href="https://github.com/eduardocp/HotChocolateFluentValidation" target="_blank">https://github.com/eduardocp/HotChocolateFluentValidation</a>