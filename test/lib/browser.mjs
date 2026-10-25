// Shared helpers for the page check, the screenshots and the recording. Talks only to the local demo Redmine.
import { chromium } from "playwright-core"
import { existsSync, readFileSync } from "node:fs"

export const config = JSON.parse(readFileSync(new URL("../config.json", import.meta.url), "utf8"))
export const pages = JSON.parse(readFileSync(new URL("../pages.json", import.meta.url), "utf8"))
export const baseUrl = process.env.DEMO_URL || `http://localhost:${config.port}`
export const schemes = ["light", "dark"]

const chromeCandidates = [
  process.env.CHROME_PATH,
  "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome",
  "/usr/bin/google-chrome",
  "/usr/bin/google-chrome-stable",
  "/usr/bin/chromium"
]

export function launch() {
  const executablePath = chromeCandidates.find((candidate) => candidate && existsSync(candidate))
  if (!executablePath) throw new Error("No Chrome found. Set CHROME_PATH to a Chrome or Chromium binary.")
  return chromium.launch({ executablePath, headless: true })
}

export async function signIn(page) {
  await page.goto(`${baseUrl}/login`)
  await page.fill("#username", "admin")
  await page.fill("#password", "admin")
  await Promise.all([page.waitForURL((url) => !url.pathname.startsWith("/login")), page.click("#login-submit")])
}

// A context that is signed in as the demo administrator, in the given colour scheme and width.
export async function signedInContext(browser, { colorScheme, width = 1280, height = 800, ...options }) {
  const setup = await browser.newContext({ colorScheme, viewport: { width, height } })
  await signIn(await setup.newPage())
  const storageState = await setup.storageState()
  await setup.close()
  return browser.newContext({ colorScheme, viewport: { width, height }, storageState, ...options })
}

// Pages marked "optional" belong to something that may not be installed (the to-do plugin). They are left out when Redmine answers
// with an error for them, so a checkout without the plugin still passes.
export async function skipUnavailable(context, entries) {
  const available = []
  for (const entry of entries) {
    if (!entry.optional || (await context.request.get(`${baseUrl}${entry.path}`)).ok()) available.push(entry)
  }
  return available
}

export function argumentValue(name, fallback) {
  const index = process.argv.indexOf(`--${name}`)
  return index === -1 ? fallback : process.argv[index + 1]
}

export const flag = (name) => process.argv.includes(`--${name}`)
