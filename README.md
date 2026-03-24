# Git Persona Bar

Catchy SwiftBar plugin to switch **Git + SSH identity** from your macOS menu bar.

- ✅ Up to **5 profiles**
- ✅ One-click switching in SwiftBar
- ✅ Updates global Git identity (`user.name`, `user.email`)
- ✅ Updates SSH identity per host in a **managed block** in `~/.ssh/config`
- ✅ Optional CLI wizard to add profiles quickly

---

## What it changes

When you switch profile, the plugin updates:

1. `git config --global user.name`
2. `git config --global user.email`
3. A managed block in `~/.ssh/config` for the configured host:

```ssh
# >>> git-persona-bar:github.com >>>
Host github.com
  AddKeysToAgent yes
  UseKeychain yes
  IdentitiesOnly yes
  IdentityFile ~/.ssh/your_key
# <<< git-persona-bar:github.com <<<
```

It also runs:

- `ssh-add -D` (clear current loaded keys)
- `ssh-add <selected-key>`

---

## Requirements

- macOS
- [SwiftBar](https://swiftbar.app/)
- `bash`, `python3`, `git`, `ssh-add`

---

## Install

```bash
git clone https://github.com/IryArkhy/git-persona-bar.git ~/Pet/git-persona-bar
cd ~/Pet/git-persona-bar
./scripts/install.sh
```

Then in SwiftBar:

- Refresh plugins, or restart SwiftBar.

---

## Configure profiles

Config file:

```text
~/.config/git-persona-bar/profiles.json
```

Create/edit it manually from template:

```bash
mkdir -p ~/.config/git-persona-bar
cp ~/Pet/git-persona-bar/config/profiles.example.json ~/.config/git-persona-bar/profiles.json
open ~/.config/git-persona-bar/profiles.json
```

Or use the wizard:

```bash
~/Pet/git-persona-bar/scripts/add-profile.sh
```

---

## Profile format

```json
{
  "profiles": [
    {
      "id": "work",
      "label": "Work",
      "icon": "💼",
      "git": {
        "name": "Your Name",
        "email": "you@company.com"
      },
      "ssh": {
        "host": "github.com",
        "identity_file": "~/.ssh/id_rsa_work"
      }
    }
  ]
}
```

### Limits

- Max profiles: **5**
- Profile IDs must be unique and use: `a-z A-Z 0-9 _ -`

---

## Notes & safety

- Do **not** commit private SSH keys.
- Use key paths only (e.g. `~/.ssh/id_ed25519_work`).
- Plugin creates timestamped backup copies of `~/.ssh/config` before updates.
- If config becomes invalid, plugin shows a warning icon and gives quick actions.

---

## Development

Run locally:

```bash
bash ./git-persona-bar.5s.sh
```

Validate config:

```bash
bash ./git-persona-bar.5s.sh validate
```

---

## License

MIT
