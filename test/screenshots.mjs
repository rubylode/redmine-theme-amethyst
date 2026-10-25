// Screenshots of the pages marked "screenshot": true, in light and dark, from the demo Redmine, for the README.
//
//   npm run screenshots                 all of them into docs/screenshots
//   npm run screenshots -- --page issue one page
import { mkdirSync } from "node:fs"
import { argumentValue, baseUrl, launch, pages, schemes, signedInContext, skipUnavailable } from "./lib/browser.mjs"

const out = new URL("../docs/screenshots/", import.meta.url).pathname
mkdirSync(out, { recursive: true })
const onlyPage = argumentValue("page")

const browser = await launch()
for (const colorScheme of schemes) {
  const signedIn = await signedInContext(browser, { colorScheme, width: 1280, height: 800 })
  const anonymous = await browser.newContext({ colorScheme, viewport: { width: 1280, height: 800 } })
  for (const entry of await skipUnavailable(signedIn, pages.filter((page) => page.screenshot && (!onlyPage || page.name === onlyPage)))) {
    const page = await (entry.signedIn ? signedIn : anonymous).newPage()
    await page.goto(`${baseUrl}${entry.path}`, { waitUntil: "load" })
    await page.waitForLoadState("networkidle").catch(() => {})
    await page.mouse.move(2, 2)
    await page.screenshot({ path: `${out}${entry.name}-${colorScheme}.png` })
    console.log("saved", `${entry.name}-${colorScheme}.png`)
    await page.close()
  }
  await signedIn.close()
  await anonymous.close()
}
await browser.close()
