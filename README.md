# Taskintosh

A minimal, aesthetic macOS menu bar todo app with a built-in reward shop and points system.

<img width="452" height="606" alt="Screenshot 2026-02-22 at 10 40 43 PM" src="https://github.com/user-attachments/assets/a940b1fd-1eef-4246-9c53-520346f5a6b9" />


## Features

- **Tasks View** - Weekly calendar strip, daily task list, mark complete to earn points
- **Shop View** - Define custom rewards and redeem them with your points  
- **Points View** - Balance stats, completion ring, full transaction history
- **Local persistence** - All data saved via UserDefaults 

---

## Requirements

- macOS 13.0 (Ventura) or later
- Xcode 15 or later

---

## Getting Started

```bash
git clone https://github.com/yourusername/taskintosh.git
cd taskintosh
open taskintosh.xcodeproj
```

Then in Xcode hit `Cmd+R`. The app won't appear in the Dock - look for the icon in your menu bar top right.

---

## Project Files

```
taskintosh/
    ├── taskintoshApp.swift
    ├── ContentView.swift
    ├── TasksView.swift
    ├── AddTaskSheet.swift
    ├── ShopView.swift
    ├── AppStoreView.swift
    ├── PointsView.swift
    └── PointsView.swift
```


## How Points Work

1. **Create tasks** - assign any point value (10, 25, 50, 100, 200, or custom)
2. **Complete tasks** - tap the checkbox, points are instantly added
3. **Uncomplete** - if you made a mistake, tap again to subtract
4. **Shop rewards** - define anything (coffee break, takeout, episode night, day off)
5. **Redeem** - when you have enough points, hit Redeem and enjoy!

---

## Potential Extensions (Future)

| Feature | Tech |
|---------|------|
| Streak tracking | SwiftData |
| macOS Widgets | WidgetKit |
| CLI companion (`task add`, `task complete`) | Rust + FFI |
| Sync across devices | CloudKit |
| Notification reminders | UserNotifications |
| CSV export | Foundation |

