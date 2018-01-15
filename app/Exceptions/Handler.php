<?php

namespace App\Exceptions;

use Exception;
use Illuminate\Support\Facades\Route;
use Illuminate\Session\TokenMismatchException;
use Illuminate\Validation\ValidationException;
use Illuminate\Auth\Access\AuthorizationException;
use Illuminate\Database\Eloquent\ModelNotFoundException;
use Symfony\Component\HttpKernel\Exception\HttpException;
use Illuminate\Foundation\Exceptions\Handler as ExceptionHandler;
use Tymon\JWTAuth\Exceptions\TokenExpiredException;
use Tymon\JWTAuth\Exceptions\TokenInvalidException;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;

class Handler extends ExceptionHandler
{
    /**
     * A list of the exception types that should not be reported.
     *
     * @var array
     */
    protected $dontReport = [
        AuthorizationException::class,
        HttpException::class,
        ModelNotFoundException::class,
        TokenMismatchException::class,
        ValidationException::class,
    ];

    /**
     * Report or log an exception.
     *
     * This is a great spot to send exceptions to Sentry, Bugsnag, etc.
     *
     * @param  \Exception  $e
     * @return void
     */
    public function report(Exception $e)
    {
        parent::report($e);
    }

    /**
     * Render an exception into an HTTP response.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \Exception  $e
     * @return \Illuminate\Http\Response
     */
    public function render($request, Exception $e)
    {
        if ($e instanceof ModelNotFoundException) {
            return response()->json([], 404);
        } else if ($e instanceof TokenExpiredException) {
            return response()->json(['error' => 'token_expired'], $e->getStatusCode());
        } else if ($e instanceof TokenInvalidException) {
            return response()->json(['error' => 'token_invalid'], $e->getStatusCode());
        }
        if($e instanceof NotFoundHttpException) {
            if ($request->segment(1) && $request->segment(1) == 'api') {
                return parent::render($request, $e);
            }

            if (!isset(Route::getRoutes()->get('GET')[$request->path()])) {
                return response()->view('index');
            }
        }

        return parent::render($request, $e);
    }
}
