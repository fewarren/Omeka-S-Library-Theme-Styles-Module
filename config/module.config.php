<?php declare(strict_types=1);

namespace LibraryThemeStyles;

use LibraryThemeStyles\Controller\AdminController;

return [
    'router' => [
        'routes' => [
            'admin' => [
                'child_routes' => [
                    'library-theme-styles' => [
                        'type' => 'Literal',
                        'options' => [
                            'route' => '/library-theme-styles',
                            'defaults' => [
                                'controller' => AdminController::class,
                                'action' => 'index',
                            ],
                        ],
                    ],
                ],
            ],
        ],
    ],

    'controllers' => [
        'factories' => [
            AdminController::class => function($sm){
                return new AdminController($sm->get('Omeka\ApiManager'));
            },
        ],
    ],

    'view_manager' => [
        'template_path_stack' => [__DIR__ . '/../view'],
    ],
];

