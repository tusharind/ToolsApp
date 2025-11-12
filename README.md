Factory Management App 

A SwiftUI-based iOS application for managing factories, employees, products, and related entities. Currently, only the Owner flow is fully implemented.

Features (Owner Flow)

Login Credentials:
  email: owner@gmail.com
  password: 12345

Employees

  View employees filtered by role (Worker, Chief Supervisor) and factory.
  Search employees by name or email.
  Scrollable, searchable factory filter.
  Profile image support with placeholders.

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

Technical Details

  Built with SwiftUI and Combine.
  Uses @StateObject & @Published for state management.
  Async network calls with a central APIClient.
  Dynamic search & filtering with debounce.
  Scrollable horizontal filters for factories.
  Compatible with iOS 16+, optimized for iOS 17 syntax.

Here is the Folder Structure.

ToolsApp/
├── App/
│   ├── AppEntry
│   ├── AppState
│   └── RootView
├── Core/
│   ├── Models/
│   │   └── Auth
│   └── Network/
│       ├── Endpoint
│       ├── Helpers
│       ├── Interceptors
│       └── Models/
│           ├── APIClient
│           ├── APIRequest
│           ├── HTTPMethod
│           ├── NetworkConfig
│           ├── NetworkError
│           └── ResponseHandler
├── Extensions/
│   ├── DataExtension
│   ├── DateExtension
│   └── DecoderExtension
└── Features/
    ├── Authentication/
    │   ├── Models
    │   ├── Repository
    │   ├── View
    │   └── ViewModel
    └── Owner/
        ├── Models
        ├── View/
        │   ├── Dashboard
        │   ├── Employees
        │   ├── Factory
        │   ├── Product
        │   └── Profile
        └── ViewModel/
            ├── Dashboard
            ├── Employees
            ├── Factories
            └── Products

            
            

            


     
