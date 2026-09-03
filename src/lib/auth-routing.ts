const callbackPath = '/auth/callback'

export function buildAuthCallbackUrl(origin: string): string {
  return new URL(callbackPath, origin).toString()
}

export function safeNextPath(next: string | null | undefined): string {
  return next?.startsWith('/') && !next.startsWith('//') ? next : '/'
}
