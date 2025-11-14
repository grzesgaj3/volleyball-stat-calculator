# volleyball-stat-calculator

A Flutter application for tracking volleyball player statistics during matches.

## Features

- **Match Setup**: Enter match title
- **Player Management**: Add players with first name, last name, number, and position
  - **CSV Import**: Import players from CSV file (format: firstname,lastname,position,number)
- **Statistics Tracking**: Track player actions across multiple sets with improved UI
  - Attack
  - Serve
  - Block
  - Reception
  - Dig
  - Grid layout for better visibility
  - Larger fonts and clear icons
- **Three-level Scoring**: Each action has three counters with intuitive icons:
  - Plus (+): Successful action (green circle with +)
  - Minus (-): Error (red circle with -)
  - Star (★): Exceptional performance (orange star icon)
- **Set Management**: Track statistics across 5 sets
- **Effectiveness Statistics**: View calculated effectiveness percentages for each player and action
- **Export Statistics**: Export all statistics to Excel spreadsheet (.xlsx)

## Supported Platforms

- Windows
- Android
- Web

## Getting Started

### Prerequisites

- Flutter SDK (>=3.0.0)
- For Windows: Windows 10 or later
- For Android: Android Studio with Android SDK
- For Web: Chrome browser

### Installation

1. Clone the repository:
```bash
git clone https://github.com/grzesgaj3/volleyball-stat-calculator.git
cd volleyball-stat-calculator
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the application:

For Windows:
```bash
flutter run -d windows
```

For Android:
```bash
flutter run -d android
```

For Web:
```bash
flutter run -d chrome
```

## How to Use

1. **Enter Match Title**: Start by entering a title for your match

2. **Add Players**: 
   - **Manual Entry**: Add players one by one with their details:
     - First Name
     - Last Name
     - Number
     - Position (Setter, Outside Hitter, Middle Blocker, Opposite, Libero)
   - **CSV Import**: Click the upload icon in the app bar to import players from a CSV file
     - CSV format: `firstname,lastname,position,number`
     - Example: `John,Doe,Setter,1`
     - See `example_players.csv` for reference

3. **Track Statistics**: 
   - Select the current set (1-5)
   - Each player is displayed in a card with a grid of action types
   - For each action type (Attack, Serve, Block, Reception, Dig), use the counters:
     - **Green (+)**: Click the green add icon for successful actions
     - **Red (-)**: Click the red add icon for errors
     - **Orange (★)**: Click the orange star icon for exceptional plays
   - Click the minus icons to decrement any counter if needed
   - Improved grid layout shows all actions clearly for each player

4. **View Statistics**: 
   - Click "View Statistics" to see effectiveness percentages for each player and action
   - Click the download icon in the app bar to export statistics to Excel (.xlsx)
   - The Excel file will be saved to your device's Documents folder

## Effectiveness Calculation

Effectiveness is calculated as: `((Plus + Star) / Total) × 100%`

- Green (≥70%): Excellent performance
- Orange (50-69%): Good performance
- Red (<50%): Needs improvement

## License

See LICENSE file for details
