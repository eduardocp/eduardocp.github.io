---
layout: post
permalink: /understanding-dependency-injection
title: "Understanding Dependency Injection in .NET Core: A Beginner's Guide"
cover-img: /assets/img/covers/2024-11-04-understanding-dependency-injection.png
thumbnail-img: /assets/img/covers/2024-11-04-understanding-dependency-injection.png
date: 2024-11-04 06:00:00
gh-repo: eduardocp/eduardocp.github.io
gh-badge: [star, follow]
tags: [dotnet, c#, dependency injection, tutorial]
comments: true
author: Eduardo Carísio
---

Have you ever wondered how modern .NET applications manage their components and services so efficiently? That's where Dependency Injection (DI) comes in! Think of DI as a way to make your code more like LEGO blocks - easily connectable, replaceable, and maintainable. In this guide, we'll break down this important concept into easy-to-understand pieces.

## What You'll Learn
- What Dependency Injection is and why it matters
- How to use DI in .NET Core applications
- Best practices for implementing DI
- Common pitfalls and how to avoid them

## Prerequisites
- Basic understanding of C#
- .NET Core SDK installed
- Visual Studio or VS Code
- Basic understanding of classes and interfaces

## What is Dependency Injection?

### The Problem It Solves
Let's start with a common scenario WITHOUT dependency injection:

```csharp
public class EmailService
{
    private SmtpClient _smtpClient;

    public EmailService()
    {
        // Hard-coded dependency
        _smtpClient = new SmtpClient("smtp.myserver.com");
    }

    public void SendEmail(string to, string subject, string body)
    {
        // Send email logic
    }
}

public class UserService
{
    private EmailService _emailService;

    public UserService()
    {
        // Creating dependency directly
        _emailService = new EmailService();
    }

    public void RegisterUser(string email)
    {
        // Register user logic
        _emailService.SendEmail(email, "Welcome!", "Welcome to our service!");
    }
}
```

Problems with this approach:
1. Hard to test (can't easily replace EmailService with a mock)
2. Tightly coupled code
3. Hard to change implementations
4. Difficult to manage dependencies

### The Solution: Dependency Injection
Here's the same code WITH dependency injection:

```csharp
public interface IEmailService
{
    void SendEmail(string to, string subject, string body);
}

public class EmailService : IEmailService
{
    private readonly ISmtpClient _smtpClient;

    // Dependencies are injected through constructor
    public EmailService(ISmtpClient smtpClient)
    {
        _smtpClient = smtpClient;
    }

    public void SendEmail(string to, string subject, string body)
    {
        // Send email logic
    }
}

public class UserService
{
    private readonly IEmailService _emailService;

    // Dependency is injected
    public UserService(IEmailService emailService)
    {
        _emailService = emailService;
    }

    public void RegisterUser(string email)
    {
        // Register user logic
        _emailService.SendEmail(email, "Welcome!", "Welcome to our service!");
    }
}
```

## Understanding the Built-in DI Container in .NET Core

### Registering Services
In your `Program.cs` or `Startup.cs`:

```csharp
var builder = WebApplication.CreateBuilder(args);

// Register services
builder.Services.AddTransient<IEmailService, EmailService>();
builder.Services.AddScoped<IUserService, UserService>();
builder.Services.AddSingleton<IConfiguration, Configuration>();
```

### Service Lifetimes Explained

1. **Transient** (AddTransient)
   - Created every time they're requested
   - Best for lightweight, stateless services
```csharp
builder.Services.AddTransient<IMyService, MyService>();
```

2. **Scoped** (AddScoped)
   - Created once per client request (in web applications)
   - Perfect for services that should be shared within a request
```csharp
builder.Services.AddScoped<IOrderService, OrderService>();
```

3. **Singleton** (AddSingleton)
   - Created only once and reused for all requests
   - Use for services that should be shared across the application
```csharp
builder.Services.AddSingleton<ICacheService, CacheService>();
```

## Real-World Example: Building a Book Library System

```csharp
// Interfaces
public interface IBookRepository
{
    List<Book> GetAllBooks();
    Book GetBookById(int id);
    void AddBook(Book book);
}

public interface ILibraryService
{
    List<Book> GetAvailableBooks();
    bool BorrowBook(int bookId, string userId);
}

// Implementations
public class BookRepository : IBookRepository
{
    private readonly ILogger<BookRepository> _logger;
    private readonly DatabaseContext _context;

    public BookRepository(
        ILogger<BookRepository> logger,
        DatabaseContext context)
    {
        _logger = logger;
        _context = context;
    }

    public List<Book> GetAllBooks()
    {
        _logger.LogInformation("Fetching all books");
        return _context.Books.ToList();
    }

    // Other implementation methods...
}

public class LibraryService : ILibraryService
{
    private readonly IBookRepository _bookRepository;
    private readonly IUserService _userService;

    public LibraryService(
        IBookRepository bookRepository,
        IUserService userService)
    {
        _bookRepository = bookRepository;
        _userService = userService;
    }

    public List<Book> GetAvailableBooks()
    {
        return _bookRepository
            .GetAllBooks()
            .Where(b => b.IsAvailable)
            .ToList();
    }

    // Other implementation methods...
}

// Registration in Program.cs
var builder = WebApplication.CreateBuilder(args);

builder.Services.AddScoped<IBookRepository, BookRepository>();
builder.Services.AddScoped<ILibraryService, LibraryService>();
builder.Services.AddScoped<IUserService, UserService>();
```

## Common Patterns with DI

### Constructor Injection (Recommended Pattern)
This is the primary and recommended way to implement dependency injection in .NET Core:

```csharp
public class OrderService
{
    private readonly IRepository _repository;
    private readonly ILogger<OrderService> _logger;

    public OrderService(IRepository repository, ILogger<OrderService> logger)
    {
        _repository = repository ?? throw new ArgumentNullException(nameof(repository));
        _logger = logger ?? throw new ArgumentNullException(nameof(logger));
    }
}
```

### Method Injection (Special Cases)
Method injection in .NET Core is primarily used in framework-specific scenarios, particularly in ASP.NET Core:

1. Action Injection in Controllers:
```csharp
public class WeatherController : ControllerBase
{
    // Regular constructor injection
    private readonly ILogger<WeatherController> _logger;

    public WeatherController(ILogger<WeatherController> logger)
    {
        _logger = logger;
    }

    // Method injection in action method
    public IActionResult Get([FromServices] IWeatherService weatherService)
    {
        var forecast = weatherService.GetForecast();
        return Ok(forecast);
    }
}
```

2. Minimal API Endpoints:
```csharp
app.MapGet("/weather", (
    [FromServices] IWeatherService weatherService,
    [FromServices] ILogger<Program> logger) =>
{
    logger.LogInformation("Fetching weather");
    return weatherService.GetForecast();
});
```

3. Razor Pages:
```csharp
public class IndexModel : PageModel
{
    public async Task OnGet([FromServices] IWeatherService weatherService)
    {
        // Use weatherService
    }
}
```

❌ Don't use Method Injection for:
```csharp
// This won't work with .NET's DI container
public class OrderProcessor
{
    public void ProcessOrder(Order order, IPaymentService paymentService)
    {
        paymentService.ProcessPayment(order); // paymentService won't be injected
    }
}
```

✅ Instead, use Constructor Injection:
```csharp
public class OrderProcessor
{
    private readonly IPaymentService _paymentService;

    public OrderProcessor(IPaymentService paymentService)
    {
        _paymentService = paymentService;
    }

    public void ProcessOrder(Order order)
    {
        _paymentService.ProcessPayment(order);
    }
}
```

## Best Practices

### 1. Constructor Injection
✅ Good:
```csharp
public class UserService
{
    private readonly IRepository _repository;
    
    public UserService(IRepository repository)
    {
        _repository = repository ?? throw new ArgumentNullException(nameof(repository));
    }
}
```

### 2. Interface Segregation
✅ Good:
```csharp
public interface IUserReader
{
    User GetById(int id);
}

public interface IUserWriter
{
    void Save(User user);
}

public class UserService : IUserReader, IUserWriter
{
    // Implementation
}
```

### 3. Avoid Service Locator
❌ Bad:
```csharp
public class UserService
{
    public void DoSomething()
    {
        var service = ServiceLocator.Current.GetInstance<IEmailService>();
        service.SendEmail();
    }
}
```

✅ Good:
```csharp
public class UserService
{
    private readonly IEmailService _emailService;

    public UserService(IEmailService emailService)
    {
        _emailService = emailService;
    }

    public void DoSomething()
    {
        _emailService.SendEmail();
    }
}
```

## Common Pitfalls and Solutions

### 1. Circular Dependencies
❌ Problem:
```csharp
public class ServiceA
{
    public ServiceA(ServiceB b) { }
}

public class ServiceB
{
    public ServiceB(ServiceA a) { } // Circular dependency!
}
```

✅ Solution:
```csharp
public class ServiceA
{
    public ServiceA(IServiceB b) { }
}

public class ServiceB
{
    public ServiceB(IServiceC c) { }
}
```

### 2. Service Locator Anti-pattern
❌ Problem:
```csharp
public class MyService
{
    public void DoWork()
    {
        var dependency = Container.Resolve<IDependency>();
    }
}
```

✅ Solution:
```csharp
public class MyService
{
    private readonly IDependency _dependency;

    public MyService(IDependency dependency)
    {
        _dependency = dependency;
    }
}
```

## Practical Exercise: Building a Weather Notification System

```csharp
public interface IWeatherService
{
    Task<WeatherInfo> GetWeatherAsync(string city);
}

public interface INotificationService
{
    Task SendNotificationAsync(string user, string message);
}

public class WeatherNotifier
{
    private readonly IWeatherService _weatherService;
    private readonly INotificationService _notificationService;
    private readonly ILogger<WeatherNotifier> _logger;

    public WeatherNotifier(
        IWeatherService weatherService,
        INotificationService notificationService,
        ILogger<WeatherNotifier> logger)
    {
        _weatherService = weatherService;
        _notificationService = notificationService;
        _logger = logger;
    }

    public async Task NotifyUserAboutWeatherAsync(string user, string city)
    {
        try
        {
            var weather = await _weatherService.GetWeatherAsync(city);
            var message = $"Current weather in {city}: {weather.Temperature}°C, {weather.Condition}";
            await _notificationService.SendNotificationAsync(user, message);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to notify user about weather");
            throw;
        }
    }
}

// Registration
builder.Services.AddScoped<IWeatherService, WeatherService>();
builder.Services.AddScoped<INotificationService, NotificationService>();
builder.Services.AddScoped<WeatherNotifier>();
```

## Testing with Dependency Injection

```csharp
public class WeatherNotifierTests
{
    [Fact]
    public async Task NotifyUserAboutWeather_Success()
    {
        // Arrange
        var mockWeatherService = new Mock<IWeatherService>();
        var mockNotificationService = new Mock<INotificationService>();
        var mockLogger = new Mock<ILogger<WeatherNotifier>>();

        mockWeatherService
            .Setup(s => s.GetWeatherAsync(It.IsAny<string>()))
            .ReturnsAsync(new WeatherInfo { Temperature = 20, Condition = "Sunny" });

        var notifier = new WeatherNotifier(
            mockWeatherService.Object,
            mockNotificationService.Object,
            mockLogger.Object);

        // Act
        await notifier.NotifyUserAboutWeatherAsync("user1", "London");

        // Assert
        mockNotificationService.Verify(
            s => s.SendNotificationAsync(
                "user1",
                It.Is<string>(msg => msg.Contains("20°C") && msg.Contains("Sunny"))
            ),
            Times.Once
        );
    }
}
```

## Practice Exercises

### Exercise 1: Basic DI Implementation
Create a simple console application that:
1. Implements a logging system with DI
2. Has different logging implementations (Console, File)
3. Uses dependency injection to switch between implementations

### Exercise 2: Building a Shopping Cart
Create a shopping cart system with:
1. Product service
2. Cart service
3. Order service
4. Payment service
All properly implemented with DI

### Exercise 3: Advanced Scenarios
Implement a system that uses:
1. Multiple interface implementations
2. Scoped and Singleton services
3. Factory pattern with DI

## Next Steps
After mastering these basics, explore:
1. Advanced DI patterns
2. DI with async/await
3. DI in specific frameworks (ASP.NET Core MVC, Blazor)
4. Third-party DI containers

## Additional Resources
- [Microsoft's DI Documentation](https://docs.microsoft.com/en-us/aspnet/core/fundamentals/dependency-injection)
- [Dependency Injection Principles](https://docs.microsoft.com/en-us/dotnet/core/extensions/dependency-injection-guidelines)
- [Clean Code with DI](https://docs.microsoft.com/en-us/dotnet/architecture/modern-web-apps-azure/architectural-principles#dependency-inversion)

Remember: The key to understanding DI is practice. Start with simple implementations and gradually move to more complex scenarios. Don't be afraid to experiment with different patterns and approaches!
