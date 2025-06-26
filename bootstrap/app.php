<?php

use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;
use Illuminate\Http\Middleware\HandleCors; // Import the built-in HandleCors middleware

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__.'/../routes/web.php',
        api: __DIR__.'/../routes/api.php',
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware) {
        // Apply CORS middleware specifically to the 'api' middleware group.
        // This ensures that your /api/login endpoint (and any other API routes)
        // will have the necessary CORS headers.

        // For development, we'll configure it to allow requests from your frontend's origin.
        // In production, you'd typically replace '*' with your actual frontend domain.
        $middleware->api(append: [
            HandleCors::class, // Add the built-in CORS middleware
        ]);

        // If you need to customize the CORS rules (e.g., allowed origins, methods, headers),
        // you would typically define them in config/cors.php.
        // Laravel 11 usually ships with a default cors.php that you can modify.
        // If config/cors.php doesn't exist, you can create it manually,
        // or ensure your .env has CORS_ALLOWED_ORIGINS set.
        // For simple "allow all" in development, the default behavior of HandleCors
        // combined with * in config/cors.php (or no specific restrictions) usually works.

        // Example of configuring web middleware (not directly related to your current login issue,
        // but showing where other middlewares would go)
        // $middleware->web(append: [
        //     \App\Http\Middleware\PreventRequestsDuringMaintenance::class,
        // ]);
    })
    ->withExceptions(function (Exceptions $exceptions) {
        //
    })->create();

