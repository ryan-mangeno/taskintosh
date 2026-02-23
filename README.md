# Taskintosh

A minimal, aesthetic macOS menu bar todo app with a built-in reward shop and points system.

<img width="452" height="606" alt="Screenshot 2026-02-22 at 10 40 43 PM" src="https://github.com/user-attachments/assets/a940b1fd-1eef-4246-9c53-520346f5a6b9" />


## Features

- **Tasks View** — Weekly calendar strip, daily task list, mark complete to earn points
- **Shop View** — Define custom rewards and redeem them with your points  
- **Points View** — Balance stats, completion ring, full transaction history
- **Local persistence** — All data saved via UserDefaults (JSON)

---

## Project Setup (Xcode)

### 1. Create the Project

```
File > New > Project > macOS > App
Product Name: taskintosh 
Interface: SwiftUI
Language: Swift
```

### 2. Set App Target Settings

In your target's **General** tab:
- Deployment Target: **macOS 13.0+**

In **Info.plist**, add:
```xml
<key>LSUIElement</key>
<true/>
```
This hides the app from the Dock and only shows it in the menu bar.

Copy all Swift files from this project into Xcode, maintaining the folder structure:
```
taskintosh/
├── taskintoshApp.swift
├── Models/
│   └── AppStore.swift
└── Views/
    ├── ContentView.swift
    ├── TasksView.swift
    ├── AddTaskSheet.swift
    ├── ShopView.swift
    └── PointsView.swift
```

### 4. Entitlements

In `taskintosh.entitlements`:
```xml
<key>com.apple.security.app-sandbox</key>
<false/>
```
(Or keep sandbox on — all features work either way.)

### 5. Build & Run

`Cmd+R` — the icon will appear in your menu bar. Click it!

## How Points Work

1. **Create tasks** — assign any point value (10, 25, 50, 100, 200, or custom)
2. **Complete tasks** — tap the checkbox, points are instantly added
3. **Uncomplete** — if you made a mistake, tap again to subtract
4. **Shop rewards** — define anything (coffee break, takeout, episode night, day off)
5. **Redeem** — when you have enough points, hit Redeem and enjoy!

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

---

## Why not Rust?

Rust *would* be great for a background sync daemon or a companion CLI tool, something like:

```bash
task add "Finish report" --points 100 --due today
task complete "Finish report"
task balance
```

I might write a Rust binary, expose it via Swift's `Process` API, and it would read/write the same JSON store. 
