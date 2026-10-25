// Runs inside the page (Playwright serialises it, so it must not use anything from this file's scope).
// For every visible element with its own text, finds the colour behind the text and measures the WCAG contrast ratio.
// Text over a background image or gradient cannot be measured this way and is counted as skipped.
export function auditContrast() {
  const canvas = document.createElement("canvas")
  canvas.width = canvas.height = 1
  const context = canvas.getContext("2d", { willReadFrequently: true })
  const cache = new Map()

  const parseColor = (css) => {
    if (cache.has(css)) return cache.get(css)
    let parsed
    const match = css.match(/^rgba?\(([^)]+)\)$/) || css.match(/^color\(srgb ([^)]+)\)$/)
    if (match) {
      const parts = match[1].split(/[\s,\/]+/).filter(Boolean).map(Number)
      const scale = css.startsWith("color(") ? 255 : 1
      parsed = [parts[0] * scale, parts[1] * scale, parts[2] * scale, parts.length > 3 ? parts[3] : 1]
    } else {
      // Any other colour space (oklch, lab, ...) is drawn once and read back as sRGB.
      context.clearRect(0, 0, 1, 1)
      context.fillStyle = "#000"
      context.fillStyle = css
      context.fillRect(0, 0, 1, 1)
      const [red, green, blue] = context.getImageData(0, 0, 1, 1).data
      parsed = [red, green, blue, 1]
    }
    cache.set(css, parsed)
    return parsed
  }

  const over = (top, bottom) => {
    const alpha = top[3]
    return [0, 1, 2].map((index) => top[index] * alpha + bottom[index] * (1 - alpha)).concat(1)
  }

  const luminance = ([red, green, blue]) => {
    const linear = (channel) => {
      const value = channel / 255
      return value <= 0.03928 ? value / 12.92 : ((value + 0.055) / 1.055) ** 2.4
    }
    return 0.2126 * linear(red) + 0.7152 * linear(green) + 0.0722 * linear(blue)
  }

  const ratioOf = (foreground, background) => {
    const [lighter, darker] = [luminance(foreground), luminance(background)].sort((a, b) => b - a)
    return (lighter + 0.05) / (darker + 0.05)
  }

  // The colour behind an element: its own and its ancestors' backgrounds, stacked, over the white page canvas.
  const backgroundOf = (element) => {
    const layers = []
    for (let node = element; node; node = node.parentElement) {
      const style = getComputedStyle(node)
      if (style.display === "contents") continue // paints nothing, so its background is not behind anything
      if (style.backgroundImage !== "none") return null
      const color = parseColor(style.backgroundColor)
      if (color[3] > 0) layers.push(color)
      if (color[3] >= 0.999) break
    }
    return layers.reduceRight((below, layer) => over(layer, below), [255, 255, 255, 1])
  }

  const opacityOf = (element) => {
    let opacity = 1
    for (let node = element; node; node = node.parentElement) opacity *= Number(getComputedStyle(node).opacity)
    return opacity
  }

  const describe = (element) => {
    const name = element.tagName.toLowerCase()
    const identifier = element.id ? `#${element.id}` : ""
    const classes = [...element.classList].slice(0, 2).map((className) => `.${className}`).join("")
    return `${name}${identifier}${classes}`
  }

  const ownText = (element) => [...element.childNodes].some((node) => node.nodeType === Node.TEXT_NODE && node.textContent.trim() !== "")
  const holdsValue = (element) => /^(INPUT|TEXTAREA|SELECT)$/.test(element.tagName) && (element.value || "").trim() !== "" && element.type !== "hidden"
  const ignored = /^(SCRIPT|STYLE|NOSCRIPT|OPTION|OPTGROUP|SVG|PATH|TITLE|HEAD)$/i

  const failures = []
  const seen = new Set()
  let checked = 0
  let skipped = 0

  for (const element of document.body.querySelectorAll("*")) {
    if (element instanceof SVGElement || ignored.test(element.tagName) || !(ownText(element) || holdsValue(element))) continue
    if (!element.checkVisibility({ checkOpacity: true, checkVisibilityCSS: true })) continue
    const rectangle = element.getBoundingClientRect()
    if (rectangle.width === 0 || rectangle.height === 0) continue
    if (element.closest("[disabled], [aria-disabled='true']")) continue

    const background = backgroundOf(element)
    if (!background) { skipped += 1; continue }
    const style = getComputedStyle(element)
    const opacity = opacityOf(element)
    const foreground = over([...parseColor(style.color).slice(0, 3), parseColor(style.color)[3] * opacity], background)
    const size = parseFloat(style.fontSize)
    const bold = Number(style.fontWeight) >= 700
    const large = size >= 24 || (size >= 18.66 && bold)
    const required = large ? 3 : 4.5
    const ratio = ratioOf(foreground, background)
    checked += 1
    if (ratio >= required) continue

    const key = `${describe(element)}|${style.color}|${style.backgroundColor}`
    if (seen.has(key)) continue
    seen.add(key)
    failures.push({
      element: describe(element),
      text: (element.textContent || element.value || "").trim().replace(/\s+/g, " ").slice(0, 40),
      ratio: Math.round(ratio * 100) / 100,
      required,
      foreground: style.color,
      background: `rgb(${background.slice(0, 3).map(Math.round).join(", ")})`,
      size
    })
  }
  return { checked, skipped, failures }
}
