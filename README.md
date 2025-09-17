# LibraryThemeStyles (Omeka S Module)

A helper module for Omeka S that makes it easy to apply design presets to the Library Theme, and to capture/restore a site’s current theme settings as saved defaults. Use it to keep styles consistent across sites or to revert quickly to a known-good configuration.

## Compatibility and version
- Omeka S: ^4.1.0 (see config/module.ini)
- Module version: 1.0.25
- Intended theme: “Library Theme” (theme slug defaults to `library-theme` when the active theme cannot be detected)

## How to access it
- Full toolset: Admin → Modules → LibraryThemeStyles → Configure
  - This page includes the advanced tools (inspect, verify, diff, load stored defaults, etc.).
- Quick page (minimal): /admin/library-theme-styles
  - A simple screen for the two most common actions (apply preset to site, save current settings as defaults).

## What this module does
- Apply a preset (Modern or Traditional) to a site’s Library Theme settings
- Save the current site’s Library Theme settings as the defaults for a preset (stored in Omeka settings)
- Load the stored defaults back into a site
- Verify that stored defaults and the site’s current settings match
- Inspect a specific setting, or show a short summary for quick checks

You don’t need to edit code or configuration files. All actions are exposed via the module’s admin UI.

## Presets included
- modern: opinionated headings/body/TOC/menu/pagination colors and font families, plus header/logo sizing
- traditional: a more classic palette and typography for the same areas

## Before you begin
- Know the site slug (for example: `library`).
- Pick a preset to work with: Modern or Traditional.
- The module detects the active theme and updates the correct settings bucket automatically; it falls back to `library-theme` if needed.

## Key actions (simple)
On both the Configure page and the quick page you’ll see two primary actions:

1) Apply Preset to This Site
- Applies the selected preset (Modern/Traditional) to the Library Theme settings for the site you enter.
- Use this to switch a site to a preset look.

2) Save This Site’s Current Settings as Preset Defaults
- Captures the site’s current Library Theme settings and saves them as the defaults for the chosen preset.
- Use this after you tweak settings and want those to become the new defaults for later reuse.

## Advanced tools (Configure page)
- Show Current Settings Summary
  - Reports how many settings exist for the active Library Theme bucket on the site.
- Check a specific setting by name
  - Enter a key such as `tagline_hover_background_color` to see its stored value.
- Compare to Preset
  - Shows differences between the site’s current settings and the built‑in preset map.
- Verify Defaults vs Current
  - Compares stored defaults to the site’s current settings; lists missing keys and value differences.
- Load Defaults Back into Site
  - Loads the stored defaults into the site’s theme settings.

## Typical workflows
- Roll a site to a preset look
  1. Enter Site Slug
  2. Choose preset (Modern/Traditional)
  3. Click “Apply Preset to This Site”

- Capture current look as defaults
  1. Enter Site Slug
  2. Choose preset (Modern/Traditional)
  3. Click “Save This Site’s Current Settings as Preset Defaults”
  4. Optional: Click “Verify Defaults vs Current” to confirm everything saved

- Restore from saved defaults
  1. Enter Site Slug
  2. Choose preset (Modern/Traditional)
  3. Click “Load Defaults Back into Site”
  4. Optional: “Verify Defaults vs Current” should show no differences

## How it works (technical)
- The active theme slug for the site is detected dynamically; if it cannot be determined, the module uses `library-theme` as a safe default.
- Site theme settings are stored in the namespaced key `theme_settings_<themeSlug>`. The module reads/writes this bucket and, when present, keeps the generic `theme_settings` container consistent.
- Preset “defaults” are saved in Omeka’s global settings as JSON under keys like `LibraryThemeStyles_defaults_modern` and `LibraryThemeStyles_defaults_traditional`.

## Installation
- Place this folder in your Omeka S installation at `modules/LibraryThemeStyles`.
- In Admin → Modules, click Install/Enable for “LibraryThemeStyles”.
- No database migrations are required.

## Notes
- Stored defaults are independent of theme files and can be reused across sites.
- After applying or loading values, the Theme Settings screen should reflect the stored values. If needed, refresh the page.
- If a setting doesn’t look right, use “Check a specific setting by name” to inspect the exact value.

## Troubleshooting
- “Verify defaults vs current shows defaults=0”
  - No stored defaults exist yet for that preset. Click “Save This Site’s Current Settings as Preset Defaults,” then verify again.
- “A field in the Theme Settings screen didn’t change”
  - Refresh the page. If it still doesn’t match, inspect the specific key. If the stored value looks correct but the UI differs, save the Theme Settings form once and reload. If it still doesn’t, check for customizations.

## Uninstalling
- Removing this module does not delete your site’s theme settings or the stored defaults. You can safely disable/uninstall it without losing theme configuration.
