import { expect, test } from '@playwright/test'

test('the application shell loads in Chromium', async ({ page }) => {
  await page.goto('/')

  await expect(page).toHaveTitle('Performance Tracker')
})
