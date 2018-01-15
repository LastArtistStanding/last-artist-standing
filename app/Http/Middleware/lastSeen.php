<?php

namespace App\Http\Middleware;

use Closure;
use Exception;
use Illuminate\Support\Facades\Auth;
use Tymon\JWTAuth\Facades\JWTAuth;

class lastSeen
{
    /**
     * Handle an incoming request.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \Closure  $next
     * @return mixed
     */
    public function handle($request, Closure $next)
    {
        $response = $next($request);

        $whitelist = [
            "GET:api/stats/dashboard",
            "GET:api/challenges",
            "GET:api/critiques",
            "GET:api/stats",
            "GET:api/logout",
            "POST:api/critiques",
            "POST:api/submissions",
            "POST:api/challenges"
        ];

        if (!$request->route()) {
            return $response;
        }
        if (!in_array($request->method() . ':' . $request->route()->uri(), $whitelist)) {
            return $response;
        }

        $value = $request->header('Authorization');
        if (isset($value) && $value) {
            try {
                if (Auth::check()) { // If route contacted authed user
                    Auth::user()->last_seen_now();
                } else { // Else try authing the token
                    $user = JWTAuth::parseToken()->authenticate();
                    if ($user) {
                        Auth::user()->last_seen_now();
                    }
                }
            } catch(Exception $e) { /* Ignore bad tokens in this middleware */}
        }

        return $response;
    }
}
