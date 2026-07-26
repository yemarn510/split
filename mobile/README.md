# Split My Bill (Flutter)

Mobile app mirroring the [Split My Bill](https://split-my-bill.vercel.app/) PWA UI.

## Design tokens

| Token | Hex | Use |
| --- | --- | --- |
| Main | `#102C57` | Primary navy text/buttons |
| Second | `#EADBC8` | Page background |
| Third | `#dbcebc` | Avatar rings |
| Fourth | `#8d9396` | Muted borders / overflow chips |

Font: **Quicksand** (via `google_fonts`)

## Screens

1. **Add People** – select friends, avatars, nicknames
2. **Add Items** – paid by, name, qty, price / %
3. **Assign People & Items** – participants per item
4. **Review & Split** – totals + share sheet

## Run

```bash
cd mobile
flutter pub get
flutter run
```

Requires Flutter SDK (this project targets Dart `>=2.19.6 <3.0.0`).
