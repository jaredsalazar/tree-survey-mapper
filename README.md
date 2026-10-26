# Tree Survey Mapper

A mobile-friendly browser app for mapping tree survey rows, reviewing tree profiles and photos, recording corrections, and syncing a team survey through Supabase. This repository contains the app source and setup guide only. It contains no survey rows, site tree IDs, photos, or live project credentials.

## What you need

- A Supabase project with Auth, database, Realtime, and private Storage.
- Invited user accounts for the team. Public sign-ups should remain disabled.
- Optional Google Maps Platform Map Tiles API key for Google satellite imagery. Without it, the app uses Esri imagery.
- A Vercel account if you want an online deployment.

## Set up Supabase

1. Create or open your Supabase project.
2. In **SQL Editor**, run [`supabase_setup.sql`](supabase_setup.sql). It creates the app tables, authenticated-user policies, Realtime publication entries, and private `survey-photos` bucket. Review the policies for your organization before using them.
3. In **Authentication**, disable new user sign-ups and invite each teammate. Each person signs in using their own email and password. The app does not store passwords.
4. Copy the project URL and **publishable** key from the Supabase API settings. Never use a service-role or secret key in this browser app.

## Run locally

1. Copy `config.example.js` to `config.js`.
2. Fill in `supabaseUrl`, `supabasePublishableKey`, and a survey name. Add `googleMapsApiKey` if you want Google satellite imagery.
3. To add site spokes, set `siteGroups` to objects with a `name` and an `ids` array, for example `[{"name":"North","ids":["T01","T02"]}]`. Keep real survey IDs out of a public repository.
4. Serve the folder over HTTP, such as with `python -m http.server 8000`, then open `http://localhost:8000`.
5. On first use, sign in and import the survey CSV. The team survey and photos are stored in your Supabase project, not in this repository.

`config.js` is ignored by Git. Do not add credentials or survey exports to this repository.

## Deploy to Vercel

1. Import this GitHub repository in Vercel.
2. Add these environment variables in Vercel Project Settings → Environment Variables:
   - `SUPABASE_URL`
   - `SUPABASE_PUBLISHABLE_KEY`
   - `DEFAULT_SURVEY`
   - `GOOGLE_MAPS_API_KEY` (optional)
   - `SITE_GROUPS_JSON` (optional; omit for no site spokes)
3. Deploy. `build.mjs` writes the runtime `dist/config.js` from those settings.

Environment variables keep values out of GitHub, but browser app configuration is delivered to visitors. A Supabase publishable key is meant for client apps; protect data with Auth and RLS, and never put a service-role key here. Google Maps keys are also visible in browser requests, so restrict them to your site’s referrers and the required API. If your site groups or survey itself must remain private, deploy the app behind access controls and do not place real group IDs in public client config.

## Using the app

1. Open the deployed site.
2. Sign in with an invited Supabase account. The browser keeps its Supabase session; the password is not saved.
3. Import the survey CSV, choose the ID/latitude/longitude columns, and load the survey.
4. Use **Team sync** to reconnect status; corrections and photo updates sync through Supabase.
5. Use **＋ Add tree** to add a tagged point, or **Hide tree** to hide it with a reason while retaining its record.
6. Photos go to the private Supabase Storage bucket when the team is connected.

## Data and licensing

Do not commit CSV exports, backup JSON, tree photos, corrected coordinates, email addresses, passwords, API keys, or `.env` files. A public repository makes committed contents readable by anyone. No license is included; public visibility alone does not grant permission to reuse the code.
