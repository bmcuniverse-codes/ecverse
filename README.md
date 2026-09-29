# ECVerse 2026 event site

A mobile-responsive Vite/React event website with a Supabase-backed admin area and anonymous audience feedback. All supplied flyers and the logo are bundled under `public/images/`.

## Install

1. Install Node.js 20 or newer. Run `npm install` in this directory.
2. Create a Supabase project. Run `supabase/schema.sql` in its SQL Editor.
3. Copy `.env.example` to `.env` and fill in `VITE_SUPABASE_URL` and `VITE_SUPABASE_ANON_KEY` from Supabase Project Settings → API. **Never put the service role key in this file.**
4. Create your admin account in Supabase Authentication → Users. In the SQL Editor, grant that account the admin role with the statement below, replacing the email. Only a project owner with SQL access should do this:

```sql
update auth.users
set raw_app_meta_data = coalesce(raw_app_meta_data, '{}'::jsonb) || '{"role":"admin"}'::jsonb
where email = 'your-admin@example.com';
```

Sign out and sign back in after assigning the role so the access token refreshes. Go to `/admin`. Disable public signups in Supabase Auth settings if only invited administrators should have accounts.

5. Run `npm run dev` for local development. Run `npm run build` for production; deploy the `dist/` directory to any static host and configure its SPA fallback to `index.html` for `/admin`. Add your deployed domain to Supabase Auth URL configuration.

## Before launch

- Set the ticket URL and contact email in Admin → Event. Until a ticket URL is set, the button displays a coming-soon notice. Prices are purposefully not fixed on the page.
- Add official social URLs in Admin → Socials. Empty links are hidden.
- Review the artist bios and reveal the mystery Fuji artist when confirmed. The lineup copy describes the event and avoids unverified career claims.
- Supabase's default project rate limits and bot protection may be configured for a public form. For high-volume traffic, put a server-side CAPTCHA or rate-limited endpoint in front of feedback inserts.
- The supplied artist flyers serve as photo artwork; replace image paths in Admin → Artists with approved portrait URLs if desired.

## Admin controls

The Event tab edits date, countdown, tickets, hero, text and contact details. Artists, Buttons, Socials and Sections manage those portions directly. Feedback shows response counts, mean rating, individual comments and a CSV export. Advanced accepts the complete content JSON for fields not surfaced elsewhere. Saving writes to one `site_content` row, with RLS allowing only an Auth user whose `app_metadata.role` is `admin` to update it. Anonymous visitors can submit feedback but cannot read responses. Do not store secrets in site content.

The site starts from bundled defaults. The first admin save persists the complete content in Supabase. All event times should include an explicit offset, such as `2026-12-19T19:00:00+01:00`, to keep the countdown accurate worldwide.
