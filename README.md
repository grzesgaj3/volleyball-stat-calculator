# volleyball-stat-calculator

A Flutter application for tracking volleyball player statistics during matches.

## Features

- **Match Setup**: Enter match title
- **Player Management**: Add players with first name, last name, number, and position
- **Statistics Tracking**: Track player actions across multiple sets
  - Attack
  - Serve
  - Block
  - Reception
  - Dig
- **Three-level Scoring**: Each action has three counters:
  - Plus (+): Successful action
  - Minus (-): Error
  - Star (★): Exceptional performance
- **Set Management**: Track statistics across 5 sets
- **Effectiveness Statistics**: View calculated effectiveness percentages for each player and action

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
2. **Add Players**: Add all players with their details:
   - First Name
   - Last Name
   - Number
   - Position (Setter, Outside Hitter, Middle Blocker, Opposite, Libero)
3. **Track Statistics**: 
   - Select the current set (1-5)
   - Select a player
   - For each action type, increment/decrement the appropriate counter:
     - Plus (+) for successful actions
     - Minus (-) for errors
     - Star (★) for exceptional plays
4. **View Statistics**: Click "View Statistics" to see effectiveness percentages for each player and action

## Effectiveness Calculation

Effectiveness is calculated as: `((Plus + Star) / Total) × 100%`

- Green (≥70%): Excellent performance
- Orange (50-69%): Good performance
- Red (<50%): Needs improvement

## License

See LICENSE file for details
