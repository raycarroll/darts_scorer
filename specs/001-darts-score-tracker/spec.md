# Feature Specification: Darts Score Tracker Mobile App

**Feature Branch**: `001-darts-score-tracker`
**Created**: 2025-10-23
**Status**: Draft
**Input**: User description: "Build a mobile app for recording scores from a darts match. Offer the ability to track across varying types of darts game. Make the UI a darts board that allows the user to tap on the score they got. Inform the user when they are able to finish the game and what darts they need to throw to do so"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Basic Score Recording with Visual Dartboard (Priority: P1)

As a darts player, I want to record my scores by tapping on a visual dartboard so that I can easily track my game progress without manual calculation.

**Why this priority**: This is the core MVP functionality. Without the ability to record scores via the interactive dartboard, the app has no value. This delivers immediate utility for any darts player.

**Independent Test**: Can be fully tested by starting a single-player game of 501, tapping score zones on the visual dartboard to record throws, and verifying the score decrements correctly. Delivers immediate value for solo practice sessions.

**Acceptance Scenarios**:

1. **Given** a new game of 501 has started, **When** I tap the triple-20 zone on the visual dartboard, **Then** my score decreases by 60 points and the display shows 441 remaining
2. **Given** I am mid-game with 180 points remaining, **When** I tap single-20, triple-19, and double-12 in sequence for my turn, **Then** my score decreases by (20 + 57 + 24) = 101 points to show 79 remaining
3. **Given** I have recorded scores for multiple turns, **When** I view the game screen, **Then** I can see my current score, number of darts thrown, and turn history
4. **Given** I accidentally tap the wrong zone, **When** I use the undo function, **Then** the last dart is removed and my score reverts to the previous value
5. **Given** I am recording a turn with three darts, **When** I tap a miss zone on the dartboard, **Then** the system records 0 points for that dart and allows me to continue

---

### User Story 2 - Finish Detection and Checkout Suggestions (Priority: P2)

As a darts player, I want the app to tell me when I can finish the game and suggest the dart combinations I need, so that I can improve my checkout knowledge and never miss a finish opportunity.

**Why this priority**: This adds significant strategic value beyond basic score tracking. It helps players learn optimal checkout paths and ensures they never miss a finish opportunity. Builds on P1 by enhancing the core scoring experience.

**Independent Test**: Can be tested by playing a game until reaching a finish-able score (e.g., 170 or less), then verifying the app displays a finish indicator and shows valid checkout combinations. Delivers value for players wanting to improve their checkout skills.

**Acceptance Scenarios**:

1. **Given** my remaining score is 170, **When** the score updates, **Then** the app displays "FINISH AVAILABLE" and shows checkout options like "T20-T20-Bull" or "T20-T18-D20"
2. **Given** my remaining score is 50, **When** I view checkout suggestions, **Then** the app shows multiple finish options including "D25", "T10-D10", "18-D16"
3. **Given** my remaining score is 1 (impossible to finish), **When** the score updates, **Then** the app indicates this is a "bust" score and I need to adjust my target
4. **Given** I have 60 remaining and hit T20, **When** the score updates to 0, **Then** the app recognizes this as an invalid finish (must end on a double) and marks it as a bust
5. **Given** I have 40 remaining and hit D20, **When** the score updates to 0, **Then** the app displays a win celebration and records the game completion

---

### User Story 3 - Multi-Game Type Support (Priority: P3)

As a darts enthusiast, I want to select from different game types (501, 301, Cricket, Around the Clock) so that I can use one app for all the darts games I play.

**Why this priority**: Expands the app's versatility and appeal to a broader audience. While valuable, basic 501 scoring (P1) and finish detection (P2) provide sufficient utility for initial release. This makes the app a complete darts companion.

**Independent Test**: Can be tested by selecting each game type from a menu, playing through a complete game of that type, and verifying the scoring rules and win conditions are correctly applied. Delivers value for players who enjoy variety in their darts games.

**Acceptance Scenarios**:

1. **Given** I am starting a new game, **When** I select "301" as the game type, **Then** the game initializes with 301 starting points and uses standard countdown rules
2. **Given** I am starting a new game, **When** I select "Cricket" as the game type, **Then** the scoring changes to track marks on numbers 15-20 and bulls, with the goal of closing all numbers
3. **Given** I am playing Cricket, **When** I hit three marks on 20 before my opponent closes it, **Then** my additional hits on 20 score points until my opponent closes their 20
4. **Given** I am starting a new game, **When** I select "Around the Clock" as the game type, **Then** the game requires hitting numbers 1-20 in sequence, then finishing with a bullseye
5. **Given** I have selected a game type, **When** I view the visual dartboard, **Then** the relevant scoring zones are highlighted based on the current game context (e.g., current target in Around the Clock)

---

### User Story 4 - Multi-Player Score Tracking (Priority: P4)

As a darts player, I want to track scores for multiple players in the same game so that I can use the app for competitive matches with friends.

**Why this priority**: Adds social and competitive functionality. While important for real-world usage, single-player scoring (P1-P3) provides a complete experience for practice and solo play. This enables the app to replace traditional scoreboards.

**Independent Test**: Can be tested by creating a game with 2-4 players, recording turns for each player in sequence, and verifying each player's score is tracked independently with correct turn rotation. Delivers value for social/competitive play.

**Acceptance Scenarios**:

1. **Given** I am starting a new game, **When** I add 3 players with names "Alice", "Bob", and "Charlie", **Then** the game initializes with all three players at the starting score and indicates whose turn it is
2. **Given** it is Alice's turn with 3 players, **When** Alice completes her turn (3 darts), **Then** the turn automatically advances to Bob
3. **Given** multiple players are in a game, **When** I view the game screen, **Then** I can see all players' current scores, averages, and turn history
4. **Given** Bob finishes the game, **When** the winning condition is met, **Then** the app displays Bob as the winner and offers options to start a new game or view game statistics
5. **Given** a multi-player game is in progress, **When** I need to undo a dart, **Then** the undo function only affects the current player's turn

---

### Edge Cases

- What happens when a player's score would go below zero or to exactly 1? (System must handle "bust" and revert to previous score)
- What happens when a player tries to finish on a single or triple instead of a double? (System must recognize invalid finish and treat as bust for standard 501/301)
- What happens if the user taps outside the dartboard scoring zones? (System should ignore or prompt for clarification)
- What happens when a player achieves a perfect 9-dart finish? (System should recognize and celebrate this achievement)
- What happens if the user rotates the device during a game? (Game state and visual dartboard should adapt to new orientation)
- What happens when a game is interrupted (app closed, phone call)? (Game state should be preserved and recoverable)
- What happens when multiple valid checkout paths exist for a score? (System should show multiple options, potentially ordered by difficulty or probability)
- What happens in Cricket when both players have closed a number? (Scoring on that number should be disabled for both players)

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST provide an interactive visual dartboard interface where users can tap scoring zones to record dart throws
- **FR-002**: System MUST support standard dartboard scoring zones including singles (1-20), doubles (D1-D20), triples (T1-T20), outer bull (25), and inner bull (50)
- **FR-003**: System MUST track and display current score, remaining score, and turn history for active games
- **FR-004**: System MUST support multiple game types including at minimum: 501, 301, Cricket, and Around the Clock
- **FR-005**: System MUST apply correct scoring rules for each game type (e.g., countdown for 501/301, mark-based scoring for Cricket)
- **FR-006**: System MUST detect finish opportunities when a player's remaining score is achievable in the current turn
- **FR-007**: System MUST provide checkout suggestions showing valid dart combinations to finish the game from finish-able scores
- **FR-008**: System MUST recognize and enforce the "must finish on a double" rule for standard games (501/301)
- **FR-009**: System MUST detect and handle "bust" scenarios where a score goes below zero, equals 1, or finishes on a non-double
- **FR-010**: System MUST provide an undo function to correct mistaken dart entries
- **FR-011**: System MUST support multi-player games with 2-4 players, tracking each player's score independently
- **FR-012**: System MUST manage turn rotation automatically, indicating whose turn it is currently
- **FR-013**: System MUST persist game state to allow resumption after app interruption
- **FR-014**: System MUST calculate and display player statistics including average score per dart, average per turn (3 darts), and checkout percentage
- **FR-015**: System MUST recognize game completion and display the winner with final statistics

### Assumptions

- Users are familiar with basic darts rules and scoring
- Standard dartboard layout follows international tournament specifications
- Default game type is 501 with double-out rule
- Mobile devices have touch screens with sufficient precision for dartboard zone selection
- Checkout suggestions will cover scores from 2-170 (maximum checkout range)
- Game history is retained on device for at least the last 30 days
- App will support both portrait and landscape orientations
- Players take turns in the order they were added to the game
- A "turn" consists of up to 3 darts unless the game is finished earlier
- Undo function is limited to the current turn only

### Key Entities

- **Game**: Represents a single darts match with a specific game type, starting score, players, and current state
- **Player**: Represents a participant in a game with a name, current score, turn history, and statistics
- **Turn**: Represents a single turn of up to 3 darts for a player, including individual dart scores and total score for the turn
- **Dart**: Represents a single dart throw with a zone (number), multiplier (single/double/triple/bull), and point value
- **Game Type**: Defines the rules for a specific darts game including starting conditions, scoring logic, and win conditions
- **Checkout Suggestion**: Represents a valid combination of darts to finish the game from a specific score

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can record a complete 3-dart turn in under 10 seconds using the visual dartboard interface
- **SC-002**: Users can complete an entire game of 501 (approximately 15-20 turns per player) without the app crashing or losing data
- **SC-003**: The visual dartboard accurately registers taps on the correct scoring zone with 95% accuracy for typical finger tap sizes
- **SC-004**: Checkout suggestions appear within 1 second of a score update that creates a finish opportunity
- **SC-005**: The app correctly identifies all valid checkout combinations for scores between 2-170
- **SC-006**: 90% of users can successfully switch between different game types and understand the rule differences within their first session
- **SC-007**: Multi-player games correctly track and rotate between up to 4 players without errors in turn sequence or score attribution
- **SC-008**: Game state is successfully recovered after app interruption (backgrounding, phone call, crash) in 95% of cases
- **SC-009**: Users report that the app reduces scoring errors by at least 80% compared to manual scorekeeping
- **SC-010**: The app correctly handles bust scenarios (score below 0, score of 1, invalid finish) 100% of the time
