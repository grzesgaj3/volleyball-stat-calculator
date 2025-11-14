# Volleyball Statistics Calculator - Architecture Documentation

## Overview

This Flutter application implements a complete volleyball statistics tracking system with a multi-step workflow for entering match data, tracking player performance, and calculating effectiveness statistics.

## Application Flow

```
Match Title Screen
    ↓
Player Entry Screen
    ↓
Statistics Tracking Screen
    ↓
Statistics Display Screen
```

## Architecture

### Models (`lib/models/`)

#### `player.dart`
- **Player**: Represents a volleyball player
  - `firstName`: Player's first name
  - `lastName`: Player's last name
  - `number`: Jersey number
  - `position`: Playing position (Setter, Outside Hitter, Middle Blocker, Opposite, Libero)
  - `fullName`: Computed property combining first and last name

#### `stats.dart`
- **ActionStats**: Tracks statistics for a single action in a single set
  - `plus`: Count of successful actions
  - `minus`: Count of errors
  - `star`: Count of exceptional performances
  - `total`: Total number of actions
  - `effectiveness`: Calculated as `((plus + star) / total) × 100%`

- **PlayerStats**: Manages all statistics for a player
  - `playerId`: Unique identifier for the player
  - `actionStatsBySet`: Nested map structure (actionType → set → stats)
  - `getStats(actionType, set)`: Retrieves or creates stats for a specific action and set
  - `getActionEffectiveness(actionType)`: Calculates overall effectiveness for an action across all sets
  - `getOverallEffectiveness()`: Calculates overall player effectiveness across all actions and sets

### Screens (`lib/screens/`)

#### `match_title_screen.dart`
**Purpose**: Initial screen for entering match information

**Features**:
- Text input for match title
- Form validation
- Navigation to Player Entry Screen

#### `player_entry_screen.dart`
**Purpose**: Add and manage players for the match

**Features**:
- Form for entering player details:
  - First Name and Last Name (text inputs)
  - Number (numeric input)
  - Position (dropdown selector)
- Player list display with cards
- Ability to remove players
- Validation to ensure at least one player before proceeding
- Navigation to Statistics Tracking Screen

**Positions Available**:
- Setter
- Outside Hitter
- Middle Blocker
- Opposite
- Libero

#### `stats_tracking_screen.dart`
**Purpose**: Track real-time statistics during the match

**Features**:
- Set selector (1-5 sets) using choice chips
- Player selector (horizontal scroll with choice chips)
- Action counters for each action type:
  - Attack
  - Serve
  - Block
  - Reception
  - Dig
- For each action, three counters with increment/decrement buttons:
  - Plus (+) - Green
  - Minus (-) - Red
  - Star (★) - Orange
- "View Statistics" button in app bar
- Real-time counter updates with visual feedback

**UI Components**:
- Color-coded counters for easy identification
- Increment/decrement buttons with icons
- Current player info display
- Organized card layout for each action type

#### `statistics_screen.dart`
**Purpose**: Display calculated effectiveness statistics

**Features**:
- Player cards showing:
  - Jersey number
  - Full name
  - Position
  - Overall effectiveness percentage (color-coded)
- Action breakdown for each player:
  - Individual action statistics (+, -, ★)
  - Per-action effectiveness percentage
  - Total action count
- Color-coded effectiveness indicators:
  - Green (≥70%): Excellent
  - Orange (50-69%): Good
  - Red (<50%): Needs improvement

## Data Flow

1. **Match Creation**:
   - User enters match title
   - Title stored and passed to next screen

2. **Player Setup**:
   - User adds players one by one
   - Players stored in list
   - List passed to tracking screen

3. **Statistics Tracking**:
   - Each player gets a `PlayerStats` object
   - User selects set and player
   - Counters update stats in real-time
   - Stats organized by: player → action type → set → counters

4. **Statistics Display**:
   - All player stats passed to display screen
   - Effectiveness calculated on the fly
   - Results displayed in organized cards

## Effectiveness Calculation

### Formula
```
Effectiveness = ((Plus + Star) / Total) × 100%
```

Where:
- **Plus**: Successful actions
- **Star**: Exceptional actions (also counted as successful)
- **Minus**: Errors (counted in total but not in numerator)
- **Total**: Plus + Minus + Star

### Examples

1. **Attack with 10 plus, 5 minus, 5 star**:
   - Effectiveness = ((10 + 5) / (10 + 5 + 5)) × 100 = 75%

2. **Serve with 8 plus, 2 minus, 0 star**:
   - Effectiveness = ((8 + 0) / (8 + 2 + 0)) × 100 = 80%

3. **Player overall across all actions**:
   - Sum all plus, minus, and star across all actions and sets
   - Apply same formula

## Testing

### Stats Calculation Tests (`test/stats_test.dart`)
- Tests effectiveness calculation for individual actions
- Verifies zero stats handling
- Tests cross-set statistics aggregation
- Validates overall player effectiveness calculation
- Ensures empty player stats return 0%

Run tests:
```bash
dart test/stats_test.dart
```

## File Structure
```
volleyball-stat-calculator/
├── lib/
│   ├── main.dart                           # App entry point
│   ├── models/
│   │   ├── player.dart                     # Player data model
│   │   └── stats.dart                      # Statistics data models
│   └── screens/
│       ├── match_title_screen.dart         # Step 1: Match title
│       ├── player_entry_screen.dart        # Step 2: Add players
│       ├── stats_tracking_screen.dart      # Step 3: Track stats
│       └── statistics_screen.dart          # Step 4: View results
├── test/
│   └── stats_test.dart                     # Unit tests
├── pubspec.yaml                            # Dependencies
├── analysis_options.yaml                   # Linting rules
└── README.md                               # User documentation
```

## Key Design Decisions

1. **Stateful Management**: Using setState for simple state management (appropriate for app size)
2. **Navigation**: Linear flow using Navigator.push (matches user workflow)
3. **Data Passing**: Direct parameter passing between screens (simple and explicit)
4. **Color Coding**: Visual feedback for counter types and effectiveness levels
5. **Validation**: Form validation at each step to ensure data quality
6. **Flexibility**: Support for 5 sets (standard volleyball format)

## Future Enhancements (Not Implemented)

- Persistence (save match data)
- Export statistics to CSV/PDF
- Historical match comparison
- Team-level statistics
- Advanced analytics (attack zones, timing)
- Multi-language support
