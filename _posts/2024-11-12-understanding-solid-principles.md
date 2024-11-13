---
layout: post
permalink: /2024-11-12-understanding-solid-principles
title: 'Understanding SOLID Principles in Software Development'
cover-img: /assets/img/covers/2024-11-12-understanding-solid-principles.png
thumbnail-img: /assets/img/covers/2024-11-12-understanding-solid-principles.png
date: 2024-11-12 05:00:00
gh-repo: eduardocp/eduardocp.github.io
gh-badge: [star, follow]
tags: [dotnet, c#, solid, tutorial]
comments: true
author: Eduardo Carísio
---

The SOLID principles are a set of five design principles in object-oriented programming (OOP) that help developers write more maintainable, flexible, and scalable code. The SOLID acronym stands for:

1. **Single Responsibility Principle (SRP)**: A class should have only one reason to change, meaning it should have a single responsibility or job.

2. **Open/Closed Principle (OCP)**: Software entities (classes, modules, functions, etc.) should be open for extension but closed for modification. This means you should be able to add new functionality without changing existing code.

3. **Liskov Substitution Principle (LSP)**: Subtypes must be substitutable for their base types. If you have a base class and a derived class, you should be able to use the derived class anywhere the base class is expected without breaking the application.

4. **Interface Segregation Principle (ISP)**: Clients should not be forced to depend on interfaces they do not use. Interfaces should be small and focused on specific tasks.

5. **Dependency Inversion Principle (DIP)**: High-level modules should not depend on low-level modules. Both should depend on abstractions. Abstractions should not depend on details, but details should depend on abstractions.

These principles are important because they help create software that is:

- **Maintainable**: By separating concerns and keeping classes and modules focused on single responsibilities, it becomes easier to understand, debug, and modify the codebase.

- **Extensible**: The open/closed principle allows you to add new features without having to change existing, working code, reducing the risk of introducing bugs.

- **Testable**: Well-designed, SOLID-compliant code is easier to unit test in isolation, as each component has a clear and narrow focus.

- **Flexible**: The dependency inversion principle allows you to swap out implementations more easily, making the codebase more flexible and adaptable to changing requirements.

Applying the SOLID principles takes some upfront effort, but it pays off in the long run by creating a codebase that is more maintainable, scalable, and easier to work with as the project grows in complexity.

## Examples

### Single Responsibility Principle (SRP)
The SRP states that a class should have only one reason to change. Consider an order processing system in an e-commerce application. Each component should handle a specific aspect of the order lifecycle.

```csharp
// ❌ Violating SRP - One class handling multiple responsibilities
public class Order
{
    public void CalculateTotal() { /* ... */ }
    public void SaveToDatabase() { /* ... */ }
    public void SendConfirmationEmail() { /* ... */ }
    public void ValidateInventory() { /* ... */ }
    public void ProcessPayment() { /* ... */ }
    public void GenerateInvoicePDF() { /* ... */ }
}

// This class would need to change for multiple reasons:
// 1. Business rules for price calculation change
// 2. Database schema changes
// 3. Email template needs updating
// 4. Payment gateway integration changes
// 5. PDF generation format changes
// 6. Inventory management rules change

// ✅ Following SRP - Each class has a single responsibility
public class OrderCalculator
{
    public decimal CalculateTotal(Order order)
    {
        // Handles only pricing logic
        decimal subtotal = order.Items.Sum(item => item.Price * item.Quantity);
        decimal tax = CalculateTax(subtotal);
        decimal shipping = CalculateShipping(order.ShippingAddress);
        return subtotal + tax + shipping;
    }
}

public class OrderRepository
{
    public void Save(Order order)
    {
        // Handles only data persistence
        using (var context = new OrderContext())
        {
            context.Orders.Add(order);
            context.SaveChanges();
        }
    }
}

public class OrderNotificationService
{
    public void SendConfirmationEmail(Order order)
    {
        // Handles only email notifications
        var template = LoadEmailTemplate("OrderConfirmation");
        var emailContent = PopulateTemplate(template, order);
        emailService.Send(order.CustomerEmail, emailContent);
    }
}

public class InventoryManager
{
    public bool ValidateAndUpdateInventory(Order order)
    {
        // Handles only inventory logic
        foreach (var item in order.Items)
        {
            if (!HasSufficientStock(item))
                return false;
        }
        UpdateInventoryLevels(order.Items);
        return true;
    }
}

public class PaymentProcessor
{
    public PaymentResult ProcessPayment(Order order, PaymentDetails details)
    {
        // Handles only payment processing
        var paymentGateway = CreatePaymentGateway(details.PaymentMethod);
        return paymentGateway.ProcessTransaction(order.Total, details);
    }
}

public class InvoiceGenerator
{
    public byte[] GenerateInvoice(Order order)
    {
        // Handles only invoice generation
        var template = LoadInvoiceTemplate();
        var invoiceData = PrepareInvoiceData(order);
        return GeneratePDF(template, invoiceData);
    }
}

// Orchestrating the order process
public class OrderProcessor
{
    private readonly OrderCalculator _calculator;
    private readonly OrderRepository _repository;
    private readonly OrderNotificationService _notificationService;
    private readonly InventoryManager _inventoryManager;
    private readonly PaymentProcessor _paymentProcessor;
    private readonly InvoiceGenerator _invoiceGenerator;

    public async Task<OrderResult> ProcessOrder(Order order, PaymentDetails paymentDetails)
    {
        try
        {
            // Each step is handled by a specialized class
            order.Total = _calculator.CalculateTotal(order);
            
            if (!_inventoryManager.ValidateAndUpdateInventory(order))
                return OrderResult.Failed("Insufficient inventory");
                
            var paymentResult = _paymentProcessor.ProcessPayment(order, paymentDetails);
            if (!paymentResult.Success)
                return OrderResult.Failed("Payment failed");
                
            _repository.Save(order);
            
            var invoice = _invoiceGenerator.GenerateInvoice(order);
            await _notificationService.SendConfirmationEmail(order);
            
            return OrderResult.Success(invoice);
        }
        catch (Exception ex)
        {
            // Handle exceptions
            return OrderResult.Failed(ex.Message);
        }
    }
}
```

### Open/Closed Principle (OCP)
Just as a smartphone accepts new apps without requiring hardware modifications, software components should be open for extension but closed for modification. Think of how your phone can gain new capabilities through apps while its core system remains unchanged.

```csharp
// ❌ Violating OCP - Requires modification for each new shape
public class AreaCalculator
{
    public double Calculate(string shapeType)
    {
        if (shapeType == "square") 
            return /* square calculation */;
        else if (shapeType == "circle")
            return /* circle calculation */;
        // Needs modification for each new shape
    }
}

// ✅ Following OCP - Extensible design
public interface IShape
{
    double CalculateArea();
}

public class Square : IShape
{
    public double Side { get; set; }
    public double CalculateArea() => Side * Side;
}

public class Circle : IShape
{
    public double Radius { get; set; }
    public double CalculateArea() => Math.PI * Radius * Radius;
}

// Adding new shapes without modifying existing code
public class Triangle : IShape
{
    public double Base { get; set; }
    public double Height { get; set; }
    public double CalculateArea() => (Base * Height) / 2;
}
```

### Liskov Substitution Principle (LSP)
Consider how any qualified pilot can fly any commercial aircraft of the same class - the specific aircraft model may change, but the fundamental principles of flight remain the same. Similarly, in software, objects of a superclass should be replaceable with objects of its subclasses without breaking the application.

```csharp
// ❌ Violating LSP - Subclass breaks expected behavior
public class Bird
{
    public virtual void Fly()
    {
        Console.WriteLine("Flying in the air");
    }
}

public class Duck : Bird
{
    public override void Fly()
    {
        throw new Exception("Cannot fly"); // Breaks expected behavior
    }
}

// ✅ Following LSP - Proper abstraction of capabilities
public interface ISwimmable
{
    void Swim();
}

public interface IFlyable
{
    void Fly();
}

public class Duck : ISwimmable
{
    public void Swim() 
    {
        Console.WriteLine("Swimming in water");
    }
}

public class Eagle : IFlyable
{
    public void Fly() 
    {
        Console.WriteLine("Soaring in the air");
    }
}
```

### Interface Segregation Principle (ISP)
Think of a restaurant menu - instead of having one massive menu with everything from breakfast to dinner, restaurants typically provide separate menus for different meals and purposes (breakfast menu, beverage menu, dessert menu). This makes it easier for customers to find what they need. Similarly, in software, it's better to have multiple focused interfaces rather than one large, general-purpose interface.

```csharp
// ❌ Violating ISP - Interface too broad
public interface IAllToys
{
    void Speak();
    void Walk();
    void Fly();
    void SwimUnderwater();
    void ShootLasers();
}

// ✅ Following ISP - Segregated interfaces
public interface ISpeakable
{
    void Speak();
}

public interface IWalkable
{
    void Walk();
}

public interface IFlyable
{
    void Fly();
}

public class Robot : ISpeakable, IWalkable
{
    public void Speak() 
    {
        Console.WriteLine("Voice interface activated");
    }
    
    public void Walk() 
    {
        Console.WriteLine("Bipedal movement engaged");
    }
}
```

### Dependency Inversion Principle (DIP)
Consider how electrical appliances work with standardized power outlets rather than being hardwired into the building's electrical system. The appliance (high-level module) isn't directly dependent on the specific power source (low-level module) - instead, both depend on the standard power outlet specification (abstraction). This same principle applies to software components.

```csharp
// ❌ Violating DIP - Direct dependency on concrete implementation
public class VideoGame
{
    private XBoxController controller;

    public VideoGame()
    {
        controller = new XBoxController();
    }
}

// ✅ Following DIP - Depending on abstraction
public interface IGameController
{
    void PressButton();
    void MoveJoystick();
}

public class XBoxController : IGameController
{
    public void PressButton() { /* ... */ }
    public void MoveJoystick() { /* ... */ }
}

public class PlayStationController : IGameController
{
    public void PressButton() { /* ... */ }
    public void MoveJoystick() { /* ... */ }
}

public class VideoGame
{
    private readonly IGameController controller;

    public VideoGame(IGameController gameController)
    {
        controller = gameController;
    }
}
```

## Conclusion

The SOLID principles serve as a cornerstone of modern software design, providing a robust framework for creating maintainable and scalable applications. While implementing these principles may require additional planning and effort initially, they help prevent technical debt and make codebases more resilient to change. As demonstrated in the examples, each principle addresses a specific aspect of software design, and when applied together, they create a foundation for building systems that are both flexible and sustainable. Whether you're developing a new application or refactoring existing code, keeping SOLID principles in mind will lead to better architectural decisions and more manageable software in the long run.