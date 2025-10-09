<?php declare(strict_types=1);

namespace LibraryThemeStyles;

use Omeka\Module\AbstractModule;
use Laminas\View\Renderer\PhpRenderer;
use Laminas\Mvc\Controller\AbstractController;
use Laminas\View\Model\ViewModel;
use LibraryThemeStyles\Service\PresetManager;
use LibraryThemeStyles\Service\ModuleConfigService;
use LibraryThemeStyles\Service\ThemeSettingsService;
use LibraryThemeStyles\Service\ErrorHandler;
use LibraryThemeStyles\Config\ModuleConfig;

class Module extends AbstractModule
{
    public function getConfig(): array
    {
        return include __DIR__ . '/config/module.config.php';
    }

    // Explicitly mark module configurable to ensure Configure link appears
    public function isConfigurable(): bool
    {
        return true;
    }

    // Expose a Configure button in Modules list and render our admin form
    public function getConfigForm(PhpRenderer $renderer)
    {
        // Render a fragment that Omeka wraps in its own form with CSRF token
        $view = new ViewModel();
        $view->setTemplate('library-theme-styles/admin/configure');
        return $renderer->render($view);
    }

    // Handle form submission from the module's Configure page (Omeka signature)
    public function handleConfigForm(AbstractController $controller): bool
    {
        $services = $controller->getEvent()->getApplication()->getServiceManager();
        $api = $services->get('Omeka\ApiManager');
        $settings = $services->get('Omeka\Settings');
        $siteSettings = $services->get('Omeka\Settings\Site');
        $messenger = $controller->messenger();

        // Initialize services
        $errorHandler = new ErrorHandler();
        $themeSettingsService = new ThemeSettingsService($api, $settings, $siteSettings, $errorHandler);
        $moduleConfigService = new ModuleConfigService($api, $settings, $siteSettings, $themeSettingsService, $errorHandler);

        $data = $controller->params()->fromPost();

        // Delegate to service
        return $moduleConfigService->handleConfigFormSubmission($data, $messenger);
    }

    /**
     * Get preset map for backward compatibility
     * @deprecated Use PresetManager::getAllPresets() directly
     */
    private function getPresetMap(): array
    {
        return PresetManager::getAllPresets();
    }
}

