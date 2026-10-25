// The page check. Loads every page of pages.json on the demo Redmine in light and dark, at desktop and phone width, and fails on:
// a console error, a failed request, sideways scrolling, or text below WCAG AA contrast.
// Pages marked "gate": false are reported but never fail the run.
//
//   npm run check                      all pages, both colour schemes
//   npm run check -- --page issue      one page
//   npm run check -- --scheme dark     one colour scheme
//   npm run check -- --report-only     print everything, always exit 0
import { mkdirSync, writeFileSync } from "node:fs"
import { argumentValue, baseUrl, flag, launch, pages, schemes, signedInContext, skipUnavailable } from "./lib/browser.mjs"
import { auditContrast } from "./lib/contrast.mjs"

const widths = [{ name: "desktop", width: 1280, height: 800 }, { name: "phone", width: 390, height: 844 }]
const onlyPage = argumentValue("page")
const onlyScheme = argumentValue("scheme")
const reportOnly = flag("report-only")
const selectedPages = pages.filter((page) => !onlyPage || page.name === onlyPage)
const selectedSchemes = schemes.filter((scheme) => !onlyScheme || scheme === onlyScheme)

const browser = await launch()
const results = []

for (const colorScheme of selectedSchemes) {
  for (const size of widths) {
    const signedIn = await signedInContext(browser, { colorScheme, width: size.width, height: size.height })
    const anonymous = await browser.newContext({ colorScheme, viewport: { width: size.width, height: size.height } })
    for (const entry of await skipUnavailable(signedIn, selectedPages)) {
      const page = await (entry.signedIn ? signedIn : anonymous).newPage()
      const problems = []
      page.on("console", (message) => message.type() === "error" && problems.push(`console: ${message.text().slice(0, 160)}`))
      page.on("pageerror", (error) => problems.push(`script error: ${error.message.slice(0, 160)}`))
      page.on("requestfailed", (request) => problems.push(`request failed: ${request.url().replace(baseUrl, "")}`))
      page.on("response", (response) => response.status() >= 400 && problems.push(`HTTP ${response.status()}: ${response.url().replace(baseUrl, "")}`))

      await page.goto(`${baseUrl}${entry.path}`, { waitUntil: "load" })
      await page.waitForLoadState("networkidle").catch(() => {})
      const overflow = await page.evaluate(() => document.documentElement.scrollWidth - window.innerWidth)
      const contrast = await page.evaluate(auditContrast)
      results.push({ page: entry.name, gate: entry.gate, scheme: colorScheme, size: size.name, problems, overflow: Math.max(0, overflow), contrast })
      await page.close()
    }
    await signedIn.close()
    await anonymous.close()
  }
}
await browser.close()

let gateFailures = 0
for (const result of results) {
  const contrastFailures = result.contrast ? result.contrast.failures : []
  const failed = result.problems.length > 0 || result.overflow > 1 || contrastFailures.length > 0
  if (failed && result.gate) gateFailures += 1
  const label = !failed ? "ok  " : result.gate ? "FAIL" : "info"
  const measured = result.contrast ? `, ${result.contrast.checked} text pairs measured, ${result.contrast.skipped} skipped` : ""
  console.log(`${label} ${result.page.padEnd(16)} ${result.scheme.padEnd(5)} ${result.size.padEnd(7)}${measured}`)
  if (!failed) continue
  result.problems.slice(0, 5).forEach((problem) => console.log(`       ${problem}`))
  if (result.overflow > 1) console.log(`       scrolls sideways by ${result.overflow}px`)
  contrastFailures.slice(0, 8).forEach((item) => console.log(`       contrast ${item.ratio} (needs ${item.required}) ${item.element} "${item.text}" ${item.foreground} on ${item.background}`))
  if (contrastFailures.length > 8) console.log(`       and ${contrastFailures.length - 8} more`)
}

mkdirSync(new URL("../tmp/", import.meta.url), { recursive: true })
writeFileSync(new URL("../tmp/check-report.json", import.meta.url), JSON.stringify(results, null, 2))
const total = results.filter((result) => result.gate).length
console.log(`\n${total - gateFailures} of ${total} gated page runs clean. Full report: tmp/check-report.json`)
process.exit(gateFailures > 0 && !reportOnly ? 1 : 0)
