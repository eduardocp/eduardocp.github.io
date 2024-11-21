---
layout: post
permalink: /hot-chocolate-case-insensitive
redirect_from:
  - /2024-08-13-hot-chocolate-case-insensitive
title: Hot Chocolate GraphQL string comparison case insensitive
date: 2024-08-13 22:00:00
cover-img: https://camo.githubusercontent.com/1232fcfc89c329dad97528011ffe5d29ab825009eca3f96fc1c063ee5babb2dd/68747470733a2f2f6368696c6c69637265616d2e636f6d2f7265736f75726365732f6368696c6c69637265616d2d6772617068716c2d62616e6e65722e737667
thumbnail-img: https://api.nuget.org/v3-flatcontainer/hotchocolate/13.9.11/icon
share-img: https://api.nuget.org/v3-flatcontainer/hotchocolate/13.9.11/icon
gh-repo: eduardocp/eduardocp.github.io
gh-badge: [star, follow]
tags: [graphql, dotnet, hot chocolate, postgresql, c#]
comments: true
author: Eduardo Carísio
---

Providing case-insensitive query support in a Hot Chocolate GraphQL server enhances the search experience for users by allowing queries to match regardless of case. This guide covers how to implement case-insensitive queries, including creating a custom `QueryableStringOperationHandler`.

## Background

Hot Chocolate is a .NET GraphQL server implementation that facilitates building GraphQL APIs. By default, GraphQL queries are case-sensitive, which may not always meet user expectations. To address this, we can create custom handlers to manage case-insensitive queries.

## Goal

The goal is to enable case-insensitive queries in your Hot Chocolate GraphQL server. This involves creating and integrating a custom `QueryableStringOperationHandler` to handle case-insensitive string operations.

## Steps to Implement Case-Insensitive Queries

### 1. Understand the Problem

GraphQL queries are case-sensitive by default. For example, a query filter like `name: "example"` will not match "Example" unless you handle case insensitivity explicitly.

### 2. Create a Custom `QueryableStringOperationHandler`

To handle case-insensitive queries effectively, you need a custom `QueryableStringOperationHandler`. This handler will manage case-insensitive string containment operations.

#### a. Implement the Custom Handler

Create a new class that inherits from `QueryableStringOperationHandler`:

```csharp
using HotChocolate.Data.Filters;
using HotChocolate.Data.Filters.Expressions;
using HotChocolate.Language;
using HotChocolate.Types;
using Microsoft.EntityFrameworkCore;
using System.Linq.Expressions;
using System.Reflection;

public class QueryableStringInvariantContainsHandler : QueryableStringOperationHandler
{
    public QueryableStringInvariantContainsHandler(InputParser inputParser)
           : base(inputParser)
    { }

    private static readonly MethodInfo _toLower = typeof(string)
        .GetMethods()
        .Single(x => x.Name == nameof(string.ToLower) && x.GetParameters().Length == 0);

    protected override int Operation => DefaultFilterOperations.Contains;

    public override Expression HandleOperation(QueryableFilterContext context,
                                               IFilterOperationField field,
                                               IValueNode value,
                                               object parsedValue)
    {
        Expression property = context.GetInstance();

        if (parsedValue is string str)
        {
            return Expression.Call(typeof(NpgsqlDbFunctionsExtensions),
                                   nameof(NpgsqlDbFunctionsExtensions.ILike),
                                   Type.EmptyTypes,
                                   Expression.Property(null, typeof(EF), nameof(EF.Functions)),
                                   property,
                                   Expression.Constant($"%{str}%"));
        }

        if (parsedValue == null && field.RuntimeType?.Source == typeof(string))
        {
            return Expression.Equal(Expression.Call(property, _toLower), Expression.Constant(null));
        }

        throw new InvalidOperationException();
    }
}
```

This handler overrides the `HandleOperation` method to perform a case-insensitive "contains" operation changing the expression to use `ILIKE` operation.

#### b. Register the Handler

Register the custom handler in your service configuration to ensure it is used for case-insensitive string operations:

```csharp
services
    .AddGraphQLServer()
    .AddFiltering()
    .AddSorting()
    .AddQueryType<Query>()
    .AddConvention<IFilterConvention>(new FilterConventionExtension(x => x.AddProviderExtension(new QueryableFilterProviderExtension(y => y.AddFieldHandler<QueryableStringInvariantContainsHandler>()))));
```

This setup integrates the custom handler into the Hot Chocolate GraphQL server.

### 3. Modify Your Data Source

Adjust your data querying logic to use case-insensitive operations. For databases, this typically involves:

- **SQL Databases**: Using `ILIKE` for PostgreSQL or similar case-insensitive search mechanisms.
- **NoSQL Databases**: Implementing case-insensitive search options based on the database technology.

Example for a SQL query in PostgreSQL:

```sql
SELECT * FROM users WHERE LOWER(name) LIKE LOWER(@name);
```

This query converts both the column value and the search term to lowercase for case-insensitive matching.

### 4. Test Case-Insensitive Queries

Conduct thorough testing to ensure that case-insensitive queries function correctly. Test with various case variations and edge cases to ensure the handler operates as expected.

### 5. Optimize Performance

Consider performance optimizations for case-insensitive searches:

- **Indexes**: Create case-insensitive indexes on frequently queried columns. For PostgreSQL:

  ```sql
  CREATE INDEX idx_users_name ON users (LOWER(name));
  ```
<span> </span>
- **Caching**: Implement caching strategies to improve performance for frequent queries.

## Conclusion

To support case-insensitive queries in a Hot Chocolate GraphQL server, you can create and integrate a custom `QueryableStringOperationHandler`. This handler enables case-insensitive "contains" operations, making it easier for users to perform searches regardless of case. By adjusting both your GraphQL resolvers and data querying logic, you enhance the flexibility and usability of your GraphQL API, ensuring a better search experience.

By following these steps, including the creation and registration of the custom handler, you provide a more intuitive and user-friendly search capability within your Hot Chocolate GraphQL server.