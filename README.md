# Dota2 Config Switcher for macOS

Easily sync your Dota 2 config files between multiple Steam accounts on the same Mac. Keeps hotkeys, minimap settings, scripts, and preferences consistent — without the need to manually export or touch cloud sync.

## ✨ Features

- 🧭 **Interactive mode**: pick accounts from a numbered list  
- 🔍 **Info mode**: see login + profile name for any account  
- ⚙️ **Direct copy**: sync settings via CLI  
- 🧠 **Safe**: uses `rsync`, makes timestamped backups  
- ☁️ **Steam-aware**: won’t run while Steam is active  
- 🔁 **Supports three copy modes**:  
  - `remote` – Steam Cloud–synced config (`remote/cfg`)  
  - `local` – machine-specific overrides (`local/cfg`)  
  - `both` – everything  

## 📦 Install

    git clone https://github.com/yourname/dota2-config-switcher.git
    cd dota2-config-switcher
    chmod +x dota2-sync.sh

(Optionally symlink to path:)

    ln -s "$PWD/dota2-sync.sh" /usr/local/bin/dota2-sync

## 🚀 Usage

### Interactive

    ./dota2-sync.sh

Lists all accounts and asks which one to copy from/to.

### Info mode

    ./dota2-sync.sh 64801769

Shows login name, profile nickname, and SteamID for any user folder.

### Direct copy

    ./dota2-sync.sh 64801769 123445667

Syncs config directly from one account to another (after confirmation).

## 📁 What gets copied

| COPY_MODE | Path           | Contents                          |
|-----------|----------------|-----------------------------------|
| remote    | `remote/cfg`   | hotkeys, Dota in-game settings    |
| local     | `local/cfg`    | `autoexec.cfg`, custom scripts    |
| both      | both of above  | full configuration sync           |

## 🛡️ Safety

- Warns if Steam is running (to avoid sync conflicts)
- Creates timestamped backups of existing configs before overwriting
- Uses `rsync` to preserve timestamps and avoid redundant copies

## 🧠 Why?

Steam doesn't let you easily share or sync configs across accounts. This helps if you:

- Use smurf accounts  
- Share a Mac with teammates or family  
- Experiment with different in-game setups  

