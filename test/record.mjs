// Records a real walk through the demo Redmine in headless Chrome and turns it into a GIF with ffmpeg.
// A drawn or mocked-up animation is not accepted; this is the page as the theme renders it.
//
//   npm run record                  light and dark, into docs/demo
//   npm run record -- --scheme dark one colour scheme
//
// Needs ffmpeg on the PATH. Playwright's video recorder also wants an ffmpeg at
// ~/Library/Caches/ms-playwright/ffmpeg-<n>/ffmpeg-mac (macOS); link the system one there if it complains.
import { spawnSync } from "node:child_process"
import { mkdirSync, readdirSync, rmSync } from "node:fs"
import { argumentValue, baseUrl, launch, schemes, signedInContext } from "./lib/browser.mjs"

const size = { width: 1100, height: 700 }
const demoDir = new URL("../docs/demo/", import.meta.url).pathname
const videoDir = new URL("../tmp/video/", import.meta.url).pathname
mkdirSync(demoDir, { recursive: true })
const onlyScheme = argumentValue("scheme")

const browser = await launch()
for (const colorScheme of schemes.filter((scheme) => !onlyScheme || scheme === onlyScheme)) {
  rmSync(videoDir, { recursive: true, force: true })
  mkdirSync(videoDir, { recursive: true })
  const context = await signedInContext(browser, { colorScheme, ...size, recordVideo: { dir: videoDir, size } })
  // A headless browser draws no pointer, so one is drawn on the page for the video.
  await context.addInitScript(() => {
    window.addEventListener("DOMContentLoaded", () => {
      const dot = document.createElement("div")
      dot.style.cssText = "position:fixed;z-index:2147483647;width:16px;height:16px;border-radius:50%;background:rgba(255,80,60,.55);border:2px solid #fff;box-shadow:0 0 4px #0008;pointer-events:none;left:-40px;top:-40px;transform:translate(-50%,-50%)"
      document.documentElement.appendChild(dot)
      window.addEventListener("mousemove", (event) => { dot.style.left = `${event.clientX}px`; dot.style.top = `${event.clientY}px` }, true)
    })
  })
  const page = await context.newPage()
  const pause = (milliseconds) => page.waitForTimeout(milliseconds)
  const glide = async (locator) => {
    const box = await locator.boundingBox()
    await page.mouse.move(box.x + box.width / 2, box.y + box.height / 2, { steps: 18 })
  }

  // 1. The project, then its issue list from the menu.
  await page.goto(`${baseUrl}/projects/atlas`); await pause(1800)
  await glide(page.locator("#main-menu a.issues")); await page.click("#main-menu a.issues")
  await page.waitForSelector("table.issues"); await pause(1600)

  // 2. Down the list, onto a row.
  await glide(page.locator("table.issues tbody tr").nth(3)); await pause(900)
  await glide(page.locator("table.issues tbody tr").nth(6)); await pause(900)

  // 3. Open the showcase issue and scroll through it.
  const showcase = page.locator("table.issues td.subject a", { hasText: "Tiles near the poles" }).first()
  await glide(showcase); await showcase.click()
  await page.waitForSelector("div.issue"); await pause(1800)
  await page.mouse.wheel(0, 500); await pause(1300)
  await page.mouse.wheel(0, 700); await pause(1300)

  // 4. The wiki, from the menu.
  await page.goto(`${baseUrl}/projects/atlas`); await pause(700)
  await glide(page.locator("#main-menu a.wiki")); await page.click("#main-menu a.wiki")
  await page.waitForSelector("#content div.wiki:not(.wiki-preview)"); await pause(1600)
  await page.mouse.wheel(0, 450); await pause(1300)

  // 5. The to-do page, when the plugin is installed in the demo.
  if ((await context.request.get(`${baseUrl}/projects/atlas/todo`)).ok()) {
    await page.goto(`${baseUrl}/projects/atlas/todo`); await pause(2200)
  }

  // 6. The new-issue form, filled in but not sent.
  await page.goto(`${baseUrl}/projects/atlas/issues/new`); await pause(1200)
  await glide(page.locator("#issue_subject")); await page.click("#issue_subject")
  await page.keyboard.type("Add a scale bar to the print view", { delay: 60 }); await pause(1500)

  await context.close()
  const video = readdirSync(videoDir).find((name) => name.endsWith(".webm"))
  const gif = `${demoDir}walkthrough-${colorScheme}.gif`
  const filter = "fps=10,scale=800:-1:flags=lanczos,split[a][b];[a]palettegen=max_colors=96[p];[b][p]paletteuse=dither=bayer:bayer_scale=5"
  const converted = spawnSync("ffmpeg", ["-y", "-loglevel", "error", "-i", `${videoDir}${video}`, "-vf", filter, gif], { stdio: "inherit" })
  if (converted.status !== 0) throw new Error("ffmpeg failed")
  console.log("recorded", gif)
}
await browser.close()
