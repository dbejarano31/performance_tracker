import { buildAuthCallbackUrl } from './lib/auth-routing'

// Keeps the callback contract discoverable without exposing any secrets.
void buildAuthCallbackUrl(window.location.origin)
