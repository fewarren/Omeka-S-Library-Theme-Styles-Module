# LibraryThemeStyles (Omeka S Module)

A comprehensive helper module for Omeka S that provides advanced theme management capabilities for the Library Theme. Features include design preset application, theme settings backup/restore, and a modern service-oriented architecture for reliable theme configuration management.

## Features

- **Design Presets**: Apply Modern or Traditional design presets to sites
- **Settings Management**: Backup and restore theme settings across sites
- **Service Architecture**: Modern, maintainable codebase with comprehensive error handling
- **Advanced Tools**: Inspect, compare, and verify theme settings
- **User-Friendly Interface**: Both simple and advanced configuration options
- **Robust Error Handling**: Comprehensive validation and user-friendly error messages

## Compatibility and Version

- **Omeka S**: ^4.1.0 (see config/module.ini)
- **Module Version**: 2.0.0 (Major refactor with service architecture)
- **Intended Theme**: "Library Theme" (theme slug defaults to `library-theme` when the active theme cannot be detected)
- **PHP**: ^8.0 (with strict typing support)

## Architecture

This module follows modern PHP best practices with a service-oriented architecture:

- **PresetManager**: Centralized preset definition and management
- **ThemeSettingsService**: Business logic for theme operations
- **ModuleConfigService**: Configuration form handling
- **ErrorHandler**: Comprehensive error handling and logging
- **ModuleConfig**: Centralized configuration constants

## How to Access

### Full Toolset (Recommended)
**Admin → Modules → LibraryThemeStyles → Configure**
- Complete interface with all advanced tools
- Inspect, verify, diff, and load stored defaults
- Debug options and detailed feedback

### Quick Interface
**`/admin/library-theme-styles`**
- Simplified interface for common operations
- Apply presets and save current settings
- Ideal for routine theme management

## What This Module Does

### Core Operations
- **Apply Presets**: Apply Modern or Traditional design presets to any site
- **Save Settings**: Capture current site theme settings as preset defaults
- **Load Defaults**: Restore previously saved settings to a site
- **Verify Settings**: Compare current settings with stored defaults
- **Inspect Settings**: View individual setting values and summaries

### Advanced Features
- **Setting Comparison**: Detailed diff between current settings and presets
- **Validation**: Comprehensive input validation with user-friendly error messages
- **Logging**: Detailed operation logging for debugging and audit trails
- **Error Recovery**: Graceful handling of errors with rollback capabilities

## Presets Included

### Modern Preset
- **Typography**: Cormorant Garamond headings with Helvetica body text
- **Colors**: Warm gold primary (#b37c05) with sacred gold accents (#D4AF37)
- **Style**: Contemporary design with clean lines and modern spacing
- **Features**: Pill-style breadcrumbs and navigation elements

### Traditional Preset
- **Typography**: Georgia headings and body text for classic readability
- **Colors**: Deep navy primary (#1F3A5F) with burgundy accents (#7A1E3A)
- **Style**: Classic, academic design with traditional spacing
- **Features**: Conservative styling suitable for institutional sites

## Installation

### Requirements
- Omeka S ^4.1.0
- PHP ^8.0 with strict typing support
- LibraryTheme installed and active

### Installation Steps
1. **Download**: Place this module folder in your Omeka S installation at `modules/LibraryThemeStyles`
2. **Install**: In Admin → Modules, click Install/Enable for "LibraryThemeStyles"
3. **Configure**: Access the configuration interface via Admin → Modules → LibraryThemeStyles → Configure
4. **Verify**: Test with a site to ensure proper functionality

### No Database Changes
- No database migrations are required
- Settings are stored in Omeka's existing settings system
- Safe to install and uninstall without data loss

## Usage Guide

### Quick Start
1. **Navigate** to Admin → Modules → LibraryThemeStyles → Configure
2. **Enter Site Slug** (e.g., "library")
3. **Choose Preset** (Modern or Traditional)
4. **Click "Apply Preset to This Site"**

### Typical Workflows

#### Apply a Preset to a Site
1. Enter Site Slug
2. Choose preset (Modern/Traditional)
3. Click "Apply Preset to This Site"
4. Verify changes in the site's theme settings

#### Save Current Look as Defaults
1. Configure your site's theme settings to your liking
2. Enter Site Slug
3. Choose preset slot (Modern/Traditional)
4. Click "Save This Site's Current Settings as Preset Defaults"
5. Optional: Click "Verify Defaults vs Current" to confirm

#### Restore from Saved Defaults
1. Enter Site Slug
2. Choose preset (Modern/Traditional)
3. Click "Load Defaults Back into Site"
4. Verify: "Verify Defaults vs Current" should show no differences

### Advanced Tools

#### Inspect Theme Settings
- **Purpose**: View current theme settings summary
- **Usage**: Enter site slug and click "Show Current Settings Summary"
- **Output**: Count of settings and sample keys for verification

#### Check Specific Setting
- **Purpose**: Inspect individual setting values
- **Usage**: Enter site slug and setting key (e.g., `tagline_hover_background_color`)
- **Output**: Current value of the specified setting

#### Compare to Preset
- **Purpose**: See differences between current settings and built-in presets
- **Usage**: Enter site slug, choose preset, click "Compare to Preset"
- **Output**: List of differences with current vs. preset values

#### Verify Defaults vs Current
- **Purpose**: Compare stored defaults with current site settings
- **Usage**: Enter site slug, choose preset, click "Verify Defaults vs Current"
- **Output**: Missing keys, value differences, and match statistics

## Technical Details

### How It Works
- **Theme Detection**: Automatically detects active theme slug for the site
- **Settings Storage**: Uses namespaced keys (`theme_settings_<themeSlug>`) for site-specific settings
- **Defaults Storage**: Saves preset defaults in global settings as JSON under keys like `LibraryThemeStyles_defaults_modern`
- **Fallback Logic**: Falls back to `library-theme` slug if theme detection fails

### Service Architecture
```
Module.php
├── ModuleConfigService (Form handling)
│   ├── ThemeSettingsService (Business logic)
│   ├── ErrorHandler (Error management)
│   └── PresetManager (Preset definitions)
└── ModuleConfig (Configuration constants)
```

### Error Handling
- **Input Validation**: Comprehensive validation of all user inputs
- **Error Logging**: Detailed logging with unique error IDs for support
- **User-Friendly Messages**: Technical errors converted to understandable messages
- **Graceful Degradation**: System continues working even when errors occur

### Security Features
- **Input Sanitization**: All inputs are validated and sanitized
- **Type Safety**: Strict typing throughout the codebase
- **Error Boundaries**: Errors are contained and don't crash the system
- **Audit Trail**: All operations are logged for security and debugging

## Troubleshooting

### Common Issues

#### "Verify defaults vs current shows defaults=0"
- **Cause**: No stored defaults exist for that preset
- **Solution**: Click "Save This Site's Current Settings as Preset Defaults" first

#### "A field in the Theme Settings screen didn't change"
- **Cause**: Browser cache or form state issues
- **Solution**: 
  1. Refresh the page
  2. If still incorrect, inspect the specific key value
  3. Save the Theme Settings form once and reload
  4. Check for theme customizations that might override settings

#### "Error ID: lts_error_xxxxx"
- **Cause**: System error occurred during operation
- **Solution**: 
  1. Note the error ID for support
  2. Check the error message for specific guidance
  3. Try the operation again
  4. Contact support with the error ID if problem persists

#### "Site slug validation failed"
- **Cause**: Invalid or missing site slug
- **Solution**: 
  1. Verify the site slug exists in Admin → Sites
  2. Use exact slug (case-sensitive)
  3. Ensure site is active and accessible

### Debug Mode
Enable debug mode by checking the "Debug" option in the configuration form:
- **Before/After Counts**: Shows setting counts before and after operations
- **Sample Data**: Displays sample of stored defaults
- **Detailed Logging**: Additional information for troubleshooting

### Getting Help
1. **Check Error Messages**: Look for specific error IDs and messages
2. **Enable Debug Mode**: Use debug options for additional information
3. **Inspect Settings**: Use "Check a specific setting by name" to verify values
4. **Review Logs**: Check system logs for detailed error information

## Uninstalling

### Safe Removal
- **Settings Preserved**: Removing this module does not delete site theme settings
- **Defaults Preserved**: Stored preset defaults remain in the system
- **No Data Loss**: Safe to disable/uninstall without losing theme configuration
- **Reversible**: Can be reinstalled later with all data intact

### Clean Uninstall (Optional)
If you want to remove all traces of the module:
1. Note any stored defaults you want to keep
2. Disable the module in Admin → Modules
3. Manually remove stored defaults from global settings (keys starting with `LibraryThemeStyles_defaults_`)
4. Remove the module folder from `modules/LibraryThemeStyles`

## Development

### Contributing
- Follow PSR-12 coding standards
- Use strict typing throughout
- Add comprehensive error handling
- Include unit tests for new features
- Update documentation for changes

### Testing
- Test all operations with both Modern and Traditional presets
- Verify error handling with invalid inputs
- Test with multiple sites and theme configurations
- Ensure backward compatibility with existing installations

## Changelog

### Version 2.0.0 (Current)
- **Major Refactor**: Complete rewrite with service-oriented architecture
- **Enhanced Error Handling**: Comprehensive validation and user-friendly messages
- **Improved Performance**: Optimized code with reduced duplication
- **Better Documentation**: Complete documentation overhaul
- **Type Safety**: Full PHP 8.0+ strict typing support

### Version 1.x.x (Legacy)
- Basic preset application and settings management
- Simple error handling
- Monolithic code structure

## License

This module is released under the same license as Omeka S. See the Omeka S license for details.

## Support

For issues, questions, or contributions, please refer to the module's documentation or contact the development team with specific error IDs and detailed descriptions of problems encountered.
