# LibraryThemeStyles Module

A helper module for Omeka S that makes it easy to apply design presets to the Library Theme, and to capture/restore a site’s current theme settings as saved defaults. This is useful when you want consistent styles across sites, or a reliable way to revert to a known-good configuration.

## What this module does

- Apply a preset (Modern or Traditional) to a site’s Library Theme settings
- Save the current site’s Library Theme settings as the defaults for a preset (stored in Omeka settings)
- Load the stored defaults back into a site
- Verify that stored defaults and the site’s current settings match
- Inspect a specific setting, or show a short summary for quick checks

You don’t need to edit code or configuration files. All actions are available from the module’s Configure page.

## Before you begin

- You need the site slug (for example: `library`).
- Pick a preset to work with: Modern or Traditional.
- The module detects the active theme and updates the correct setting bucket automatically.

## Key actions (simple)

On the Configure page you’ll see two main actions:

1) Apply Preset to This Site
- Applies the selected preset (Modern/Traditional) to the Library Theme settings for the site you entered.
- Use this to quickly switch a site to a preset look.

2) Save This Site’s Current Settings as Preset Defaults
- Captures the site’s current Library Theme settings and saves them as the defaults for the chosen preset.
- Use this after you tweak settings and want those to become the New Defaults.

## Advanced tools (optional)

Open the “Advanced tools (optional)” section for these helpers:

- Show Current Settings Summary
  - Prints how many settings the site currently has for the Library Theme.
- Check a specific setting by name
  - Enter a key like `tagline_hover_background_color` and click “Check Value.”
- Compare to Preset
  - Shows differences between the current settings and the built-in preset map.
- Verify Defaults vs Current
  - Compares stored defaults to the site’s current settings and lists any missing keys or differences.
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

## Notes

- Stored defaults are saved in the Omeka S settings under a module key; they are separate from the theme files.
- The module writes into the correct place that Omeka and the theme read from on your system, so what you see in the Theme Settings screen will match the stored values after you apply or load.
- If a specific setting doesn’t look right, use “Check a specific setting by name” to inspect the exact value in storage.

## Troubleshooting

- “Verify defaults vs current shows defaults=0”
  - This means no stored defaults exist yet for that preset. Click “Save This Site’s Current Settings as Preset Defaults,” then verify again.
- “A field in the Theme Settings screen didn’t change”
  - Refresh the page. If it still doesn’t match, check the specific key’s value with the inspector. If the stored value is correct but the UI differs, save the form once and reload; the UI should pick up the stored value. If it still doesn’t, contact your administrator to check for customizations.

## Uninstalling

- Removing this module does not delete your site’s theme settings or the stored defaults. You can safely disable/uninstall it without losing your theme configuration.

# Omeka-S-Library-Theme-Styles-Module
