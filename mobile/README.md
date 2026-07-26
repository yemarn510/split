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

## Integrations

Same backend as the [PWA](https://split-my-bill.vercel.app/):

- **Google login** via Supabase Auth OAuth
- **Receipt scan** via `POST https://split-my-bill.vercel.app/scan`
- **Friends / history** via Supabase tables `friend`, `history`, `history_results`

### One-time Supabase setup

In Supabase → Authentication → URL Configuration → Redirect URLs, add:

```
com.splitmybill.app://login-callback/
```

Without this, Google login cannot return to the app.