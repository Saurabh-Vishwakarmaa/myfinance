# MyFinance - Personal Finance Tracker

## Overview
MyFinance is a Flutter app that helps users track their personal finances efficiently. The app allows users to add transactions (incomes and expenses), categorize them, view their financial history, and generate basic summaries over a given time period.

## Features
- **Transaction Management**: Add, edit, and delete transactions.
- **Category Management**: Create and manage custom categories.
- **Dashboard Overview**: View total income, expenses, and a spending breakdown by category.
- **Data Persistence**: Transactions are saved and synced using Appwrite.
- **Notifications/Reminders**: Get alerts for upcoming or recurring payments.
- **Authentication**: Secure login and data sync using Appwrite authentication.

## Installation

### Prerequisites
Ensure you have the following installed:
- Flutter SDK
- Dart
- Appwrite (self-hosted or cloud version)

### Setup Instructions
1. **Clone the Repository**
   ```sh
   git clone https://github.com/your-repo/myfinance.git
   cd myfinance
   ```
2. **Install Dependencies**
   ```sh
   flutter pub get
   ```
3. **Set Up Appwrite**
   - Create a new project in Appwrite.
   - Configure **authentication**, **database**, and **storage**.
   - Update `config.dart` with your Appwrite project credentials.

4. **Run the App**
   ```sh
   flutter run
   ```

## Project Structure
```
myfinance/
│-- lib/
│   │-- main.dart  # Entry point
│   │-- config.dart  # Appwrite configuration
│   │-- screens/
│   │   │-- dashboard_screen.dart  # Dashboard UI
│   │   │-- transactions_screen.dart  # Transaction Management
│   │   │-- categories_screen.dart  # Category Management
│   │-- models/
│   │   │-- transaction_model.dart  # Data model for transactions
│   │   │-- category_model.dart  # Data model for categories
│   │-- services/
│   │   │-- appwrite_service.dart  # Appwrite interaction
│-- pubspec.yaml  # Dependencies
│-- README.md  # Project instructions
```

## API & Data Management
- The app interacts with **Appwrite's Database** to store transactions and categories.
- **Appwrite Authentication** is used for secure user login.

## Testing
Run unit and widget tests:
```sh
flutter test
```

## Contributing
Feel free to fork this repository and submit pull requests with enhancements.

## License
MIT License. See `LICENSE` for details.

