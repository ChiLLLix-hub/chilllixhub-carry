# qb_carry – 4 Carrying Types (QBCore)

A QBCore FiveM resource that lets players physically interact with each other through four different carrying/holding animations.

---

## Features

| Mode | Description |
|------|-------------|
| **Drag** | Drag the closest player using a box-carry animation. Requires a `rope` item in the player's inventory. |
| **PiggyBack** | Attach to and piggyback the closest player with a paired animation. |
| **Carry** | Pick up the closest player using a fireman-carry animation. |
| **Take Hostage** | Hold the closest player at gunpoint (requires a pistol). Press **G** to release or **H** to kill the hostage. |

---

## How It Works

1. Stand near another player (within 2–3 metres).
2. Press **F9** to open the *4 Carrying Types* menu (powered by `qb-menu`).
3. Select the desired action from the menu.
4. The server synchronises the animation between both players and attaches their peds together.
5. Use the same menu option again (or the designated hotkeys while in hostage mode) to stop.

### Hostage controls (while actively holding a hostage)
| Key | Action |
|-----|--------|
| **G** | Release the hostage (shove animation) |
| **H** | Kill the hostage |

### Allowed weapons for Take Hostage
Edit `hostageAllowedWeapons` in `client/main.lua` to add or remove weapon names:
```lua
local hostageAllowedWeapons = {
    "WEAPON_PISTOL",
    "WEAPON_PISTOL50",
}
```

---

## Requirements

| Resource | Notes |
|----------|-------|
| [qb-core](https://github.com/qbcore-framework/qb-core) | QBCore framework |
| [qb-menu](https://github.com/qbcore-framework/qb-menu) | Context menu UI |

The `rope` item used by the **Drag** action must exist in your QBCore shared items table (`qb-core/shared/items.lua`).  
Add it if it is not already present:
```lua
['rope'] = {['name'] = 'rope', ['label'] = 'Rope', ['weight'] = 500, ['type'] = 'item', ['image'] = 'rope.png', ['unique'] = false, ['useable'] = false, ['shouldClose'] = false, ['combinable'] = nil, ['description'] = 'A piece of rope'},
```

---

## Installation

1. **Download** or clone this repository.

2. **Place** the `qb_carry` folder inside your FiveM server's `resources` directory:
   ```
   resources/
   └── qb_carry/
       ├── client/
       │   └── main.lua
       ├── server/
       │   └── main.lua
       ├── fxmanifest.lua
       └── README.md
   ```

3. **Ensure `qb-menu`** is already started before `qb_carry` in your `server.cfg`.

4. **Add** the resource to your `server.cfg`:
   ```cfg
   ensure qb-core
   ensure qb-menu
   ensure qb_carry
   ```

5. **(Optional)** Add the `rope` item to `qb-core/shared/items.lua` if you want the Drag rope-check to function (see the *Requirements* section above).

6. **Restart** your server (or use `refresh` + `start qb_carry` in the server console).

---

## Configuration

All configuration lives directly in the source files:

| File | What to change |
|------|---------------|
| `client/main.lua` | `hostageAllowedWeapons` – weapons that allow taking hostages |
| `client/main.lua` | Detection radius values (`GetClosestPlayer(3)` / `GetClosestPlayer(2)`) |
| `client/main.lua` | Key binding – default is **F9** (control index `56`) |
| `server/main.lua` | Item name for the rope check (`'rope'`) |

---

## Credits

Original script by **AOTCARIBBEAN**  
QBCore conversion by **ChiLLLix-hub**
