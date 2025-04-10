# PlanIt 📅  

A SwiftUI-based event and reminder application that helps users manage their schedules with customizable notifications, repeating events, and an intuitive calendar and list view. PlanIt ensures you never miss an event with timely alerts, including a 5-minute warning before the event and recurring reminders if needed.  

## Features  

📅 **Calendar & List Views**  
- View upcoming events in a calendar format or a detailed list  

⏰ **Event Notifications**  
- Receive notifications at the event time  
- Continuous reminders for 5 minutes after event start  
- Optional 5-minute pre-event warning  

🔄 **Repeating Events**  
- Custom repeat intervals (daily, weekly, etc.)  
- Set end dates for recurring events  

🗣️ **Coming Soon: Siri Integration**  
- Voice-controlled event creation  

🚀 **App Store Ready**  
- Polished UI designed for public release  

## Installation  

### Option 1: Local Build  
1. Clone the repository:  
   ```bash
   git clone https://github.com/yourusername/planit-app.git
   ```
2. Open in XCode:
   ```bash
   cd planit-app
   open PlanIt.xcodeproj
   ```

### Option 2: App Store (Coming Soon)
1. PlanIt is intended to be published on the App Store soon

## Usage

### Adding Events
1. Tap the "+" button
2. Set event details:
   - **Title**: Name your event
   - **Date/time**: Select start and end times
   - **Reminder preferences**:
     - 5-minute pre-event alert (optional)
     - Persistent notifications
   - **Repeat settings**: Configure recurrence

### Managing Notifications
- Notifications will appear:
  - 🔔 5 minutes before event (if enabled)
  - ⏰ At the scheduled event time
  - 🔄 Every minute for 5 minutes after start time

### Repeating Events
- **Set custom repeat intervals**:
  - Daily/Weekly/Monthly
  - Custom patterns (e.g., every 3 days)
- **Configure end conditions**:
  - After X occurrences
  - On specific end date
  - Manual stop

## Roadmap

### 🛠️ In Development
- **Siri Integration**:
  - "Hey Siri, add event to PlanIt"
  - Voice-controlled event management
