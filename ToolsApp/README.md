Factory Management App (Owner Flow)

A SwiftUI-based iOS application for managing factories, employees, products, and related entities. 

Credentials:

CHIEF OFFICE
{
   "email": "Chinmay@gmail.com",
   "password": "default123"
}

MANAGER
{
    "email": "anny.manager@factory.com",
    "password": "ANN@7823878"
}

ADMIN
{
     "email": "owner@gmail.com",     
     "password": "12345"
}

Features (Owner Flow)
Employees

View employees filtered by role (Worker, Chief Supervisor) and factory.

Search employees by name or email.

Scrollable, searchable factory filter.

Factories

View all factories with their details.

Toggle factory status (Active/Inactive).

Searchable factories list.

Products & Categories

View products in a factory.

View and search product categories.

Add new categories via modal sheet.

Managers & Central Offices

View available managers.

View central office details.

Quick Links

Dashboard-style quick access cards for Employees, Products, Categories, and Factories.

Uniform card layout with subtle colors and rounded corners.

Technical Details

Built with SwiftUI and Combine.

Uses @StateObject & @Published for state management.

Async network calls with a central APIClient.

Dynamic search & filtering with debounce.

Scrollable horizontal filters for factories.

Compatible with iOS 16+
