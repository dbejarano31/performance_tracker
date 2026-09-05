# Browser authentication test plan

## Scope for the interactive test session

The browser test session validates the real local Google OAuth flow. It must run against the local Supabase stack started through `./scripts/start-local.sh` and the Vite app at `http://localhost:5173`.

## Preconditions

- Docker local Supabase stack is running.
- `./scripts/start-local.sh` has loaded the Google OAuth values from Infisical.
- Google Console permits:
  - origin: `http://localhost:5173`
  - callback: `http://127.0.0.1:54321/auth/v1/callback`
- Test identities:
  - invited: `dbr.bejarano@gmail.com`
  - non-invited: `the.harvey.agent@gmail.com`
- The app includes an explicit Google sign-in control, callback handler, profile activation call, and authenticated/denied views. These product UI pieces are not implemented yet.

## Automated browser baseline

```bash
npm run test:e2e
```

The Playwright suite owns `tests/e2e/` and starts Vite automatically. It currently verifies that Chromium can load the application shell. Browser traces are retained on the first retry and are ignored by Git.

## Live OAuth acceptance cases

| ID | Scenario | Expected result |
|---|---|---|
| AUTH-01 | Invited user signs in with Google | Browser returns to `/auth/callback`, session exists, `activate_profile()` succeeds, and the user reaches the authenticated app view. |
| AUTH-02 | Non-invited user signs in with Google | Authentication may complete at Google, but app access is denied; no profile is created and no protected data is shown. |
| AUTH-03 | Invited user opens a protected deep link before sign-in | The validated relative `next` path is restored after profile activation. |
| AUTH-04 | `next` is an absolute or protocol-relative URL | The app rejects it and uses `/`; no open redirect occurs. |
| AUTH-05 | User cancels or Google returns an OAuth error | Callback presents an actionable error and no application session/profile is activated. |
| AUTH-06 | User signs out then refreshes | Local session is cleared; protected routes return to the sign-in view. |
| AUTH-07 | Two invited identities are exercised separately | Each user can access only their own profile/data; browser results align with the database RLS test. |

## Evidence to collect

For each live scenario, record the result, relevant URL path, browser console errors, and one screenshot if the outcome is unexpected. Do not capture or store access tokens, authorization codes, Google client secrets, or Infisical values.
