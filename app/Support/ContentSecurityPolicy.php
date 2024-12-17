<?php

namespace App\Support;

use Illuminate\Support\Facades\App;
use Spatie\Csp\Directive;
use Spatie\Csp\Keyword;
use Spatie\Csp\Policies\Policy;

class ContentSecurityPolicy extends Policy
{
    public function configure()
    {
        $this
            // default: child-src connect-src font-src frame-src img-src manifest-src media-src
            //          object-src prefetch-src script-src script-src-elem script-src-attr
            //          style-src style-src-elem style-src-attr worker-src
            ->addDirective(Directive::DEFAULT, Keyword::NONE)

            // override default
            ->addDirective(Directive::CONNECT, [Keyword::SELF]) // 'ws:', 'wss:'
            ->addDirective(Directive::FONT, [Keyword::SELF, 'fonts.bunny.net'])
            ->addDirective(Directive::IMG, [Keyword::SELF]) // 'data:'
            //->addDirective(Directive::OBJECT, Keyword::NONE)
            ->addDirective(Directive::SCRIPT, [Keyword::SELF]) // 'js-agent.newrelic.com', Keyword::UNSAFE_EVAL, Keyword::UNSAFE_INLINE
            ->addDirective(Directive::STYLE, [Keyword::SELF, 'fonts.bunny.net'])
            // ->addNonceForDirective(Directive::SCRIPT)
            // ->addNonceForDirective(Directive::STYLE)

            // not covered by default
            ->addDirective(Directive::BASE, Keyword::SELF)
            ->addDirective(Directive::FRAME_ANCESTORS, Keyword::NONE)
            ->addDirective(Directive::FORM_ACTION, Keyword::SELF);

        if (! App::environment('local')) {
            // $this
            //     ->addDirective(Directive::SCRIPT, ['js-agent.newrelic.com', 'sha256-QSxWRlL6LCqUZwMDiK/L7+df2zuqgc6Y1uj3wlY24L8=']);
        } else {
            $this
                // for vite in dev
                ->addDirective(Directive::CONNECT, 'ws://127.0.0.1:5173')
                ->addDirective(Directive::SCRIPT, '127.0.0.1:5173')
                ->addDirective(Directive::STYLE, '127.0.0.1:5173');

            if (config('csp.debugbar_enabled')) {
                $this
                    ->addDirective(Directive::FONT, 'data:')
                    ->addDirective(Directive::IMG, 'data:')
                    ->addDirective(Directive::SCRIPT, ['localhost:8000', Keyword::UNSAFE_INLINE])
                    ->addDirective(Directive::STYLE, Keyword::UNSAFE_INLINE);
            }
        }
    }
}
