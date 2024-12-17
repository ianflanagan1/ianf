<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\App;
use Symfony\Component\HttpFoundation\Response;

class SecurityHeadersForHtml
{
    public function handle(Request $request, Closure $next): Response
    {
        if (! App::environment('local')) {
            return $next($request)
                // not compatible with Vite in dev:
                ->header('Cross-Origin-Opener-Policy', 'same-origin')
                ->header('Cross-Origin-Embedder-Policy', 'require-corp')
                // deprecated:
                ->header('X-Frame-Options', 'DENY') // replaced by CSP frame-ancestors
                ->header('X-XSS-Protection', '0'); // replaced by CSP
        }

        return $next($request);
    }
}
