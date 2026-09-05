import { describe, expect, it } from 'vitest'

import { buildAuthCallbackUrl, safeNextPath } from '../src/lib/auth-routing'

describe('OAuth callback routing', () => {
  it('builds a local callback URL on the application origin', () => {
    expect(buildAuthCallbackUrl('http://localhost:5173')).toBe(
      'http://localhost:5173/auth/callback',
    )
  })

  it('keeps a relative post-login path', () => {
    expect(safeNextPath('/dashboard')).toBe('/dashboard')
  })

  it('rejects an external post-login URL', () => {
    expect(safeNextPath('https://attacker.example')).toBe('/')
  })
})
