<?php declare(strict_types=1);

namespace LibraryThemeStyles\Controller;

use Laminas\Mvc\Controller\AbstractActionController;
use Laminas\View\Model\ViewModel;
use Omeka\Api\Manager as ApiManager;
use LibraryThemeStyles\Service\PresetManager;
use LibraryThemeStyles\Config\ModuleConfig;
use LibraryThemeStyles\Service\ErrorHandler;
use LibraryThemeStyles\Service\ThemeSettingsService;

class AdminController extends AbstractActionController
{
    private ApiManager $api;
    private ErrorHandler $errorHandler;
    private ThemeSettingsService $themeSettingsService;

    /**
     * Create an AdminController with its required services.
     *
     * @param ApiManager $api Manager for performing API-related operations.
     * @param ErrorHandler $errorHandler Handles validation, error formatting, and wrapped operations.
     * @param ThemeSettingsService $themeSettingsService Service responsible for applying and saving theme preset settings.
     */
    public function __construct(
        ApiManager $api,
        ErrorHandler $errorHandler,
        ThemeSettingsService $themeSettingsService
    ) {
        $this->api = $api;
        $this->errorHandler = $errorHandler;
        $this->themeSettingsService = $themeSettingsService;
    }

    /**
     * Render and process the admin theme settings page, handling preset load/save actions.
     *
     * Processes POST requests to either apply a preset's defaults to a site's theme settings
     * ("load_defaults_into_settings") or save a site's current settings as a preset default
     * ("save_settings_as_defaults"). Validates the preset and site slug, collects success or
     * error feedback, and exposes the resulting message and error state to the view.
     *
     * @return ViewModel Contains:
     *   - `message` (string|null): success message when an action completes,
     *   - `error` (string|null): validation or operation error message,
     *   - `siteSlug` (string|null): the site query parameter passed to the action.
     */
    public function indexAction()
    {
        $request = $this->getRequest();
        $siteSlug = $this->params()->fromQuery('site', null);

        $message = null;
        $error = null;

        // Discover the LibraryTheme key for this installation
        $themeKey = ModuleConfig::DEFAULT_THEME_KEY;

        try {
            if ($request->isPost()) {
                $action = $this->params()->fromPost('action');
                $targetPreset = $this->params()->fromPost('target_preset', ModuleConfig::DEFAULT_PRESET);

                // Validate inputs
                if ($presetError = $this->errorHandler->validatePreset($targetPreset)) {
                    $error = $presetError;
                } elseif ($action === 'load_defaults_into_settings') {
                    if ($siteError = $this->errorHandler->validateSiteSlug($siteSlug)) {
                        $error = $siteError;
                    } else {
                        // Copy preset defaults into current site theme settings
                        $result = $this->errorHandler->wrapOperation(
                            fn() => $this->themeSettingsService->applyPresetToThemeSettings($siteSlug, $themeKey, $targetPreset),
                            'apply_preset_to_theme_settings'
                        );

                        if ($result['success']) {
                            [$count, $details] = $result['data'];
                            $message = ModuleConfig::getSuccessMessage('preset_applied', $count, $targetPreset);
                        } else {
                            $error = $result['error'];
                        }
                    }
                } elseif ($action === 'save_settings_as_defaults') {
                    if ($siteError = $this->errorHandler->validateSiteSlug($siteSlug)) {
                        $error = $siteError;
                    } else {
                        // Copy current settings into preset defaults (write to config storage)
                        $result = $this->errorHandler->wrapOperation(
                            fn() => $this->themeSettingsService->saveSettingsAsPresetDefaults($siteSlug, $themeKey, $targetPreset),
                            'save_settings_as_preset_defaults'
                        );

                        if ($result['success']) {
                            [$count, $details] = $result['data'];
                            $message = ModuleConfig::getSuccessMessage('settings_saved', $targetPreset, $count);
                        } else {
                            $error = $result['error'];
                        }
                    }
                } else {
                    $error = 'Unknown action.';
                }
            }
        } catch (\Throwable $e) {
            $error = $this->errorHandler->handleException($e, 'admin_controller_index_action');
        }

        return new ViewModel([
            'message' => $message,
            'error' => $error,
            'siteSlug' => $siteSlug,
        ]);
    }




}
