---
layout: post
title: Hot Chocolate GraphQL string comparison case insentive
date: 2024-08-13 22:00:00
cover-img: https://camo.githubusercontent.com/1232fcfc89c329dad97528011ffe5d29ab825009eca3f96fc1c063ee5babb2dd/68747470733a2f2f6368696c6c69637265616d2e636f6d2f7265736f75726365732f6368696c6c69637265616d2d6772617068716c2d62616e6e65722e737667
thumbnail-img: https://api.nuget.org/v3-flatcontainer/hotchocolate/13.9.11/icon
share-img: https://api.nuget.org/v3-flatcontainer/hotchocolate/13.9.11/icon
gh-repo: eduardocp/eduardocp.github.io
gh-badge: [star, fork, follow]
tags: [graphql, dotnet, hot chocolate, postgresql, c#]
comments: true
author: Eduardo Carísio
---

### Who interest this article

Developers that facing problems with filter queries by clauses: in, contains and equals (and the negative of these ones too)

### Previous knowledge

- <a href="https://graphql.org/" target="_blank">GraphQL</a>
- <a href="https://dotnet.microsoft.com/" target="_blank">.Net</a>
- <a href="https://chillicream.com/docs/hotchocolate/v13" target="_blank">Hot Chocolate</a>

### Problem

In a recent project, we have a couple of queries that our most searchable part is person names. This project use PostgreSQL as the database engine and, by default, the like clause is case sensitive.

Basically when you filter something like this:

```graphql
query {
    myQuery(where: { name: { contains: "ana" } }) {
        id
        name
    }
}
```

the translated query is (if you use <a href="https://chillicream.com/docs/hotchocolate/v13/fetching-data/projections" target="_blank">projections</a>):

```sql
SELECT t.id, t.name FROM table AS t WHERE t.name LIKE @__p_0_contains
```

{: .box-warning}
(where `@__p_0_contains` is `%ana%`)

This return a false positive because names at db like 'Ana Bolena', will not be retrieved.

### Solution

To change this behavior, first we need to understand how filter are translated to c#.
We can find this explanation at <a href="https://chillicream.com/docs/hotchocolate/v13/api-reference/extending-filtering/#filter-operation-handlers" target="_blank">Hot Chocolate docs</a>.

After understand the concept, we find an example of implementation that will help us (a lot) to get the final code.
So, lets se the code: 

{% highlight csharp linenos %}
public class QueryableStringInvariantEqualsHandler : QueryableStringOperationHandler
{
    public QueryableStringInvariantEqualsHandler(InputParser inputParser) : base(inputParser)
    {
    }

    // For creating a expression tree we need the `MethodInfo` of the `ToLower` method of string
    private static readonly MethodInfo _toLower = typeof(string)
        .GetMethods()
        .Single(x => x.Name == nameof(string.ToLower) && x.GetParameters().Length == 0);

    // This is used to match the handler to all `eq` fields
    protected override int Operation => DefaultFilterOperations.Equals;

    public override Expression HandleOperation(
        QueryableFilterContext context,
        IFilterOperationField field,
        IValueNode value,
        object parsedValue)
    {
        // We get the instance of the context. This is the expression path to the property
        // e.g. ~> y.Street
        Expression property = context.GetInstance();

        // the parsed value is what was specified in the query
        // e.g. ~> eq: "221B Baker Street"
        if (parsedValue is string str)
        {
            // Creates and returns the operation
            // e.g. ~> y.Street.ToLower() == "221b baker street"
            return Expression.Equal(Expression.Call(property, _toLower), Expression.Constant(str.ToLower()));
        }

        // Something went wrong 😱
        throw new InvalidOperationException();
    }
}
{% endhighlight %}

It's almost perfect, except for the only one scenario; `parsedValue` can be compared to `null`, in this case, the `if` inside line 27
will not activated and will throw an exception.

We fix it by adding this code after line 33:

```csharp
if (parsedValue == null && field.RuntimeType?.Source == typeof(string))
{
    return Expression.Equal(Expression.Call(property, _toLower), Expression.Constant(null));
}
```

This is the premiss to the other files.

I will not explain the file below, but fell free to text 🙂

<details>
    <summary style="font-size:1.125rem;font-family:var(--header-font);font-weight:800;line-height:1.1;margin-top:1.25rem;margin-bottom:.5rem;">QueryableStringInvariantContainsHandler</summary>
    {% highlight csharp linenos %}
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
    {% endhighlight %}
</details>

<details>
    <summary style="font-size:1.125rem;font-family:var(--header-font);font-weight:800;line-height:1.1;margin-top:1.25rem;margin-bottom:.5rem;">QueryableStringInvariantEqualsHandler</summary>
{% highlight csharp linenos %}
public class QueryableStringInvariantEqualsHandler : QueryableStringOperationHandler
{
    public QueryableStringInvariantEqualsHandler(InputParser inputParser)
           : base(inputParser)
    { }

    private static readonly MethodInfo _toLower = typeof(string)
        .GetMethods()
        .Single(x => x.Name == nameof(string.ToLower) && x.GetParameters().Length == 0);

    protected override int Operation => DefaultFilterOperations.Equals;

    public override Expression HandleOperation(QueryableFilterContext context,
                                               IFilterOperationField field,
                                               IValueNode value,
                                               object parsedValue)
    {
        Expression property = context.GetInstance();

        if (parsedValue is string castedParsedValue)
        {
            return Expression.Equal(Expression.Call(property, _toLower), Expression.Constant(castedParsedValue.ToLower()));
        }

        if (parsedValue == null && field.RuntimeType?.Source == typeof(string))
        {
            return Expression.Equal(Expression.Call(property, _toLower), Expression.Constant(null));
        }

        throw new InvalidOperationException();
    }
}
{% endhighlight %}
</details>

<details>
    <summary style="font-size:1.125rem;font-family:var(--header-font);font-weight:800;line-height:1.1;margin-top:1.25rem;margin-bottom:.5rem;">QueryableStringInvariantInHandler</summary>
{% highlight csharp linenos %}
public class QueryableStringInvariantInHandler : QueryableStringOperationHandler
{
    public QueryableStringInvariantInHandler(InputParser inputParser)
           : base(inputParser)
    { }

    private static readonly MethodInfo _toLower = typeof(string)
        .GetMethods()
        .Single(x => x.Name == nameof(string.ToLower) && x.GetParameters().Length == 0);

    private static readonly MethodInfo _contains = typeof(Enumerable).
                GetMethods().
                Where(x => x.Name == "Contains").
                Single(x => x.GetParameters().Length == 2).
                MakeGenericMethod(typeof(string));

    protected override int Operation => DefaultFilterOperations.In;

    public override Expression HandleOperation(QueryableFilterContext context,
                                               IFilterOperationField field,
                                               IValueNode value,
                                               object parsedValue)
    {
        Expression property = context.GetInstance();

        if (parsedValue is string[] str)
        {
            return Expression.Call(_contains, Expression.Constant(str), Expression.Call(property, _toLower));
        }

        throw new InvalidOperationException();
    }
}
{% endhighlight %}
</details>

<details>
    <summary style="font-size:1.125rem;font-family:var(--header-font);font-weight:800;line-height:1.1;margin-top:1.25rem;margin-bottom:.5rem;">QueryableStringInvariantNotContainsHandler</summary>
{% highlight csharp linenos %}
public class QueryableStringInvariantNotContainsHandler : QueryableStringOperationHandler
{
    public QueryableStringInvariantNotContainsHandler(InputParser inputParser)
           : base(inputParser)
    { }

    private static readonly MethodInfo _toLower = typeof(string)
        .GetMethods()
        .Single(x => x.Name == nameof(string.ToLower) && x.GetParameters().Length == 0);

    protected override int Operation => DefaultFilterOperations.NotContains;

    public override Expression HandleOperation(QueryableFilterContext context,
                                               IFilterOperationField field,
                                               IValueNode value,
                                               object parsedValue)
    {
        Expression property = context.GetInstance();

        if (parsedValue is string str)
        {
            return Expression.Not(Expression.Call(typeof(NpgsqlDbFunctionsExtensions),
                                   nameof(NpgsqlDbFunctionsExtensions.ILike),
                                   Type.EmptyTypes,
                                   Expression.Property(null, typeof(EF), nameof(EF.Functions)),
                                   property,
                                   Expression.Constant($"%{str}%")));
        }

        if (parsedValue == null && field.RuntimeType?.Source == typeof(string))
        {
            return Expression.NotEqual(Expression.Call(property, _toLower), Expression.Constant(null));
        }

        throw new InvalidOperationException();
    }
}
{% endhighlight %}
</details>

<details>
    <summary style="font-size:1.125rem;font-family:var(--header-font);font-weight:800;line-height:1.1;margin-top:1.25rem;margin-bottom:.5rem;">QueryableStringInvariantNotEqualsHandler</summary>
{% highlight csharp linenos %}
public class QueryableStringInvariantNotEqualsHandler : QueryableStringOperationHandler
{
    public QueryableStringInvariantNotEqualsHandler(InputParser inputParser)
           : base(inputParser)
    { }

    private static readonly MethodInfo _toLower = typeof(string)
        .GetMethods()
        .Single(x => x.Name == nameof(string.ToLower) && x.GetParameters().Length == 0);

    protected override int Operation => DefaultFilterOperations.NotEquals;

    public override Expression HandleOperation(QueryableFilterContext context,
                                               IFilterOperationField field,
                                               IValueNode value,
                                               object parsedValue)
    {
        Expression property = context.GetInstance();

        if (parsedValue is string castedParsedValue)
        {
            return Expression.NotEqual(Expression.Call(property, _toLower), Expression.Constant(castedParsedValue.ToLower()));
        }

        if (parsedValue == null && field.RuntimeType?.Source == typeof(string))
        {
            return Expression.NotEqual(Expression.Call(property, _toLower), Expression.Constant(null));
        }

        throw new InvalidOperationException();
    }
}
{% endhighlight %}
</details>

<details>
    <summary style="font-size:1.125rem;font-family:var(--header-font);font-weight:800;line-height:1.1;margin-top:1.25rem;margin-bottom:.5rem;">QueryableStringInvariantNotInHandler</summary>
{% highlight csharp linenos %}
public class QueryableStringInvariantNotInHandler : QueryableStringOperationHandler
{
    public QueryableStringInvariantNotInHandler(InputParser inputParser)
           : base(inputParser)
    { }

    private static readonly MethodInfo _toLower = typeof(string)
        .GetMethods()
        .Single(x => x.Name == nameof(string.ToLower) && x.GetParameters().Length == 0);

    private static readonly MethodInfo _contains = typeof(Enumerable).
                GetMethods().
                Where(x => x.Name == "Contains").
                Single(x => x.GetParameters().Length == 2).
                MakeGenericMethod(typeof(string));

    protected override int Operation => DefaultFilterOperations.NotIn;

    public override Expression HandleOperation(QueryableFilterContext context,
                                               IFilterOperationField field,
                                               IValueNode value,
                                               object parsedValue)
    {
        Expression property = context.GetInstance();

        if (parsedValue is string[] str)
        {
            return Expression.Not(Expression.Call(_contains, Expression.Constant(str), Expression.Call(property, _toLower)));
        }

        throw new InvalidOperationException();
    }
}
{% endhighlight %}
</details>

After created this files, don't forget to register this filters:

```csharp
    serviceCollection
        .AddGraphQLServer()
        .AddConvention<IFilterConvention>(new FilterConventionExtension(x => x.AddProviderExtension(new QueryableFilterProviderExtension(y => y.AddFieldHandler<QueryableStringInvariantEqualsHandler>()))));
```

Repeat the `AddConvention<>()` line for each one filter that was created.