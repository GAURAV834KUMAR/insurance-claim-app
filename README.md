# Insurance Claim Management System

A comprehensive, production-ready Flutter Web application for managing hospital insurance claims. Built with modern Flutter practices, this app demonstrates advanced architecture patterns, state management, data persistence, and beautiful UI/UX.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Material 3](https://img.shields.io/badge/Material%203-757575?style=for-the-badge&logo=materialdesign&logoColor=white)

## ✨ Key Highlights

- **Data Persistence**: Claims automatically saved to browser's localStorage
- **Dark Mode**: Toggle between light and dark themes
- **Analytics Dashboard**: Visual insights with custom-built charts
- **Export Functionality**: Download claims as CSV or individual reports
- **Custom Animations**: Smooth transitions and animated charts
- **Responsive Design**: Works on all screen sizes

## 🎯 Core Features

### Insurance Claim Creation
- Patient name with real-time validation
- Policy number tracking with format support
- Claim date selection with date picker
- Multiple bills management per claim
- Advance payment tracking
- Settlement amount management
- Draft saving functionality

### Bill Management
- Add, edit, and delete bills dynamically
- Each bill has description and amount
- Automatic calculations:
  - Total Bill Amount (sum of all bills)
  - Pending Amount (Total - Advance - Settlement)

### Claim Status Workflow
Strict status transitions enforced with clear business rules:
```
Draft → Submitted (when ready to submit)
Submitted → Approved OR Rejected (by reviewer)
Approved → Partially Settled (partial payment made)
Partially Settled → Settled (fully paid)
```

Invalid transitions are prevented with informative error messages.

### Dashboard
- View all claims at a glance with summary cards
- Real-time statistics (Total Claims, Total Value, Pending, Settled)
- Filter by status tabs (All, Draft, Submitted, Approved, Rejected, Partial, Settled)
- Full-text search by patient name or policy number
- Multi-field sorting with ascending/descending toggle
- Color-coded status chips with icons

### Analytics & Insights
- **Status Distribution**: Interactive donut chart showing claim breakdown
- **Monthly Trends**: Bar chart displaying claims over time
- **Performance Metrics**: Approval rate, settlement rate, rejection rate
- **Financial Summary**: Total amounts, averages, ranges
- **Quick Stats**: Key metrics at a glance

### Export & Reports
- **CSV Export**: Download all claims or filtered results
- **Individual Reports**: Generate detailed text reports per claim
- **Report includes**: Patient info, bills, financials, timestamps

### Data Persistence
- Automatic saving to browser localStorage
- Data survives page refreshes and browser restarts
- Sample data loaded on first visit
- Clear separation between storage and business logic

### Theme Support
- Light mode with bright, clean aesthetics
- Dark mode for reduced eye strain
- Smooth transitions between themes
- Persisted theme preference

## 🏗️ Architecture

### Clean Folder Structure
```
lib/
├── main.dart                      # App entry point with Provider setup
├── models/                        # Data models
│   ├── bill.dart                 # Bill model with serialization
│   ├── claim.dart                # Claim model with business logic
│   ├── claim_status.dart         # ClaimStatus enum with transitions
│   ├── claim_analytics.dart      # Analytics computations
│   └── models.dart               # Barrel export
├── providers/                     # State management
│   ├── claims_provider.dart      # Claims CRUD & business logic
│   ├── theme_provider.dart       # Theme state management
│   └── providers.dart            # Barrel export
├── screens/                       # App screens
│   ├── dashboard_screen.dart     # Main claims list
│   ├── claim_form_screen.dart    # Create/edit form
│   ├── claim_detail_screen.dart  # Claim details view
│   ├── analytics_screen.dart     # Analytics dashboard
│   └── screens.dart              # Barrel export
├── services/                      # External services
│   └── storage_service.dart      # localStorage & export
├── widgets/                       # Reusable components
│   ├── amount_summary_card.dart  # Financial summary widget
│   ├── animated_progress_bar.dart # Animated progress bars
│   ├── bill_dialog.dart          # Bill add/edit dialog
│   ├── bill_tile.dart            # Bill list item
│   ├── claim_card.dart           # Claim list card
│   ├── confirm_dialog.dart       # Confirmation dialogs
│   ├── empty_state.dart          # Empty state illustrations
│   ├── monthly_bar_chart.dart    # Custom bar chart
│   ├── status_pie_chart.dart     # Custom pie/donut chart
│   ├── stat_card.dart            # Statistics card
│   ├── status_chip.dart          # Status indicator chip
│   ├── status_transition_dialog.dart
│   └── widgets.dart              # Barrel export
└── utils/                         # Utilities
    ├── constants.dart            # Colors, styles, spacing
    ├── formatters.dart           # Currency, date formatting
    ├── theme.dart                # Light & dark themes
    ├── validators.dart           # Input validation
    └── utils.dart                # Barrel export
```

### Technical Highlights
- **State Management**: Provider pattern with ChangeNotifier for reactive UI
- **Clean Architecture**: Business logic separated from presentation layer
- **Type Safety**: Enums for status, strong typing throughout codebase
- **Immutable Models**: All models use copyWith pattern for state updates
- **UUID Generation**: Unique identifiers for claims and bills
- **Comprehensive Validation**: Input validation with helpful error messages
- **Custom Charts**: Built-in animated charts without external dependencies
- **Responsive Layout**: Adapts to mobile, tablet, and desktop screens

## 🎨 UI/UX Features

### Material 3 Design
- Modern Material You design language
- Consistent color scheme with status-specific colors
- Rounded corners and elevation for depth
- Smooth animations and transitions

### Responsive Design
- Adaptive layouts for different screen sizes
- Wide layout for desktop (two-column view)
- Narrow layout for mobile (single column)
- Touch-friendly interactions

### Visual Feedback
- Loading indicators for async operations
- Success/error snackbars for actions
- Confirmation dialogs for destructive actions
- Empty states with helpful messages

### Animations
- Chart animations on page load
- Card hover effects on web
- Smooth page transitions
- Theme transition animation

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.10.7 or higher
- Web browser (Chrome recommended for development)

### Installation

1. **Clone the repository**
```bash
cd insurance_claim_app
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Run the application**
```bash
flutter run -d chrome
```

### Building for Production
```bash
flutter build web --release
```

## 📦 Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `provider` | ^6.1.2 | State management |
| `uuid` | ^4.5.1 | Unique ID generation |
| `intl` | ^0.19.0 | Formatting (currency, dates) |

## 📱 Screenshots

### Dashboard
- Claims list with status filters
- Search and sort functionality
- Summary statistics cards

### Analytics
- Status distribution pie chart
- Monthly trends bar chart
- Performance metrics

### Claim Details
- Patient information card
- Bills list with amounts
- Financial summary
- Status transition controls

### Dark Mode
- Full dark theme support
- Automatic preference persistence

## 🔧 Business Rules

### Status Transitions
| Current Status | Can Transition To |
|---------------|-------------------|
| Draft | Submitted |
| Submitted | Approved, Rejected |
| Approved | Partially Settled |
| Partially Settled | Settled |
| Rejected | ❌ (Terminal) |
| Settled | ❌ (Terminal) |

### Validation Rules
- Patient name: Required, 2-100 characters
- Policy number: Required, alphanumeric, 6-20 characters
- Bill description: Required, 2-200 characters
- Bill amount: Required, must be > 0
- Advance paid: Cannot exceed total bill amount
- Settlement: Cannot exceed pending amount

## 🛠️ Development Notes

### Adding New Features
1. Create model in `lib/models/`
2. Add business logic to provider in `lib/providers/`
3. Create UI components in `lib/widgets/`
4. Build screens in `lib/screens/`
5. Update barrel exports

### Testing
```bash
flutter test
```

### Code Quality
The codebase follows:
- Effective Dart guidelines
- Clean code principles
- SOLID design patterns
- Comprehensive documentation

## 📄 License

This project is created as part of an internship assignment and is intended for educational and demonstration purposes.

## 👨‍💻 Author

Built with ❤️ using Flutter and Dart

---

**Note**: This application demonstrates professional-grade Flutter development practices including clean architecture, state management, data persistence, responsive design, and custom UI components.
