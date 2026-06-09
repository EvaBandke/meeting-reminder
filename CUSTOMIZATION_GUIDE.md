# How to Customize Your Flying Airplane Animation

## ✈️ Quick Start

1. Open `MeetingReminder.xcodeproj` in Xcode
2. Navigate to `MeetingReminder/AirplaneView.swift`
3. Make changes to the sections below
4. Press **⌘R** to build and test

---

## Appearance Changes You Can Make

### 1️⃣ **Change the Font & Text Size**

Find line 24 in `AirplaneView.swift`:
```swift
.font(.custom("Comic Sans MS", size: 28))
```

**Change the number to adjust text size:**
- Smaller: `size: 20` (tighter look)
- Larger: `size: 36` (bold & loud)
- Different font: Replace `"Comic Sans MS"` with:
  - `"Helvetica"` (clean, modern)
  - `"Courier New"` (typewriter look)
  - `"Georgia"` (elegant)

### 2️⃣ **Change Text & Banner Colors**

Find line 25:
```swift
.foregroundStyle(.white)
```

Change to one of these preset colors:
- `.white` (white text)
- `.black` (black text)
- `.blue` (blue text)
- `.red` (red text)
- `.yellow` (yellow text — use with dark banner)

**Or create a custom color:**
```swift
.foregroundStyle(Color(red: 1.0, green: 0.2, blue: 0.8))  // Hot pink example
```
RGB values range from 0.0 to 1.0.

### 3️⃣ **Make the Airplane Bigger or Smaller**

Find line 38:
```swift
.frame(width: 220, height: 220)
```

Change the numbers to resize:
- Smaller: `width: 150, height: 150`
- Larger: `width: 280, height: 280`
- Keep it proportional (same width & height)

### 4️⃣ **Adjust Spacing Between Banner & Plane**

Find line 21:
```swift
HStack(spacing: -10)
```

Change `-10` to adjust:
- `-20` = overlap more (plane goes behind banner more)
- `0` = no overlap (clean separation)
- `10` = gap between them

### 5️⃣ **Adjust Padding Around Text**

Find lines 27-28:
```swift
.padding(.horizontal, 50)  // Left/right space
.padding(.vertical, 22)     // Top/bottom space
```

Adjust to make the banner bigger or tighter:
- Smaller numbers = less padding = tighter text
- Larger numbers = more padding = roomier banner

---

## Replace the Images

The airplane and banner are PNG files. To use your own:

1. Find these folders in Xcode (left sidebar):
   - `Assets.xcassets` → `airplane.imageset` (the flying plane)
   - `Assets.xcassets` → `banner.imageset` (the pink background)

2. Right-click → **Delete** the old image
3. Drag your new image into that folder
4. Make sure it says "Attributes Inspector" → **Scales** is set to 1x, 2x, 3x

---

## Test Your Changes

**Use the built-in test:**
1. Build the app (**⌘R**)
2. Click the ✈️ menu bar icon
3. Click **Test airplane** — you'll see your changes instantly

No need to wait for a real meeting!

---

## iPhone Calendar Already Works 🎉

Since you use iCloud:
1. Events on your iPhone automatically sync to your Mac's Calendar.app
2. This app reads from Calendar.app, so it sees them automatically
3. Just grant calendar access when prompted, and you're done!

If events aren't showing, check:
- **Settings → Internet Accounts** → Make sure your iCloud account is set up
- **Calendar.app** → Make sure your calendar is visible (check the checkboxes)
- Restart this app (quit and reopen)

---

## Getting Help

- Stuck on a change? Check line numbers in `AirplaneView.swift`
- Want to undo? Press **⌘Z** to undo
- Don't see changes? Make sure you press **⌘R** to rebuild
