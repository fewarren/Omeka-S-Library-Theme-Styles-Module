<?php declare(strict_types=1);

namespace LibraryThemeStyles\Controller;

use Laminas\Mvc\Controller\AbstractActionController;
use Laminas\View\Model\ViewModel;
use LibraryThemeStyles\Service\ModuleConfigService;

class AdminController extends AbstractActionController
{
    private ModuleConfigService $moduleConfigService;

    public function __construct(ModuleConfigService $moduleConfigService)
    {
        $this->moduleConfigService = $moduleConfigService;
    }

    public function indexAction()
    {
        $request = $this->getRequest();
        $siteSlug = $this->params()->fromQuery('site', null);

        $message = null;
        $error = null;

        if ($request->isPost()) {
            // Collect form data
            $data = [
                'action' => $this->params()->fromPost('action'),
                'target_preset' => $this->params()->fromPost('target_preset'),
                'site' => $siteSlug,
            ];

            // Use ModuleConfigService to handle the form submission
            $messenger = $this->messenger();
            $success = $this->moduleConfigService->handleConfigFormSubmission($data, $messenger);

            // Extract messages from messenger
            $messages = $messenger->get();
            if (!empty($messages)) {
                if ($success) {
                    $message = implode(' ', $messages);
                } else {
                    $error = implode(' ', $messages);
                }
            }
        }

        return new ViewModel([
            'message' => $message,
            'error' => $error,
            'siteSlug' => $siteSlug,
        ]);
    }




}

