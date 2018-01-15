<?php

namespace App\Http\Controllers;

use Exception;
use GrahamCampbell\Throttle\Facades\Throttle;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

use App\User;
use Illuminate\Support\Facades\Validator;
use Tymon\JWTAuth\Exceptions\JWTException;
use Tymon\JWTAuth\Exceptions\TokenExpiredException;
use Tymon\JWTAuth\Exceptions\TokenInvalidException;
use Tymon\JWTAuth\Facades\JWTAuth;
use Illuminate\Foundation\Auth\ThrottlesLogins;
use Illuminate\Foundation\Auth\AuthenticatesAndRegistersUsers;

class AuthController extends Controller
{
    use AuthenticatesAndRegistersUsers, ThrottlesLogins;

    protected $lockoutTime = 120;

    /**
     * Where to redirect users after login / registration.
     *
     * @var string
     */
    protected $redirectTo = '/';

    public function refresh() {
        JWTAuth::parseToken();

        try {
            // Invalid the old token and get a new one.
            $newToken = JWTAuth::refresh();
        } catch (TokenExpiredException $e) {
            return response()->json(['error' => 'token_expired'], $e->getStatusCode());
        } catch (TokenInvalidException $e) {
            return response()->json(['error' => 'token_invalid'], $e->getStatusCode());
        }


        return response()->json(['token' => $newToken], 200);
    }

    public function authenticate(Request $request) {
        try {
            $throttles = $this->isUsingThrottlesLoginsTrait();
            if ($throttles && $this->hasTooManyLoginAttempts($request)) {
                $seconds = $this->secondsRemainingOnLockout($request);
                return response()->json(['error' => ['Too many login attempts. Try again in ' . $seconds . ' seconds']], 401);
            }
            if ($throttles) {
                $this->incrementLoginAttempts($request);
            }

            if (!$token = JWTAuth::attempt($request->all())) {
                return response()->json(['error' => ['Wrong credentials.']], 401);
            }
        } catch (JWTException $e) {
            return response()->json(['error' => ['Could not create an authentication token']], 500);
        }

        return response()->json(['token' => $token, 'user' => Auth::user()], 200);
    }

    public function register(Request $request) {
        $validator = $this->validator($request->all());

        // Validate before throttling to ensure the creation is going to go through in the first place.
        if ($validator->fails()) {
            return response()->json(['error' => collect($validator->errors())->flatten()], 422);
        }

        $throttler = Throttle::get($request, 1, 120); // Can create an account once every 2 hours
        if(!$throttler->attempt($request)) {
            return response()->json(['error' => ['You\'ve registered a user recently and can\'t make another one yet. Please try again later.']], 401);
        }

        $this->create($request->all());
        return $this->authenticate($request);
    }

    public function updatePassword(Request $request) {
        $user = Auth::user();

        $validator = Validator::make($request->all(), [
            'password' => 'required|min:6',
            'new_password' => 'required|min:6|confirmed'
        ]);

        if (!JWTAuth::attempt(['username' => $user->username, 'password' => $request->password])) {
            return response()->json(['error' => ['Wrong credentials.']], 401);
        }

        if ($validator->fails()) {
            return response()->json(['error' => collect($validator->errors())->flatten()], 422);
        }

        $user->password = bcrypt($request->new_password);
        return response()->json(['success' => $user->save()]);
    }

    protected function validator(array $data) {
        return Validator::make($data, [
            'username' => 'required|string|min:1|max:20|unique:users',
            'email' => 'sometimes|email|min:4|max:75|unique:users',
            'password' => 'required|min:6|confirmed'
        ]);
    }

    public function logout() {
        $token = JWTAuth::parseToken()->getToken();
        $result = JWTAuth::manager()->invalidate($token);
        return response()->json(['result' => $result], 200);
    }

    protected function create(array $data) {
        if (isset($data['email'])) {
            return User::create([
                'username' => $data['username'],
                'email' => $data['email'],
                'password' => bcrypt($data['password'])
            ]);
        }
        return User::create([
            'username' => $data['username'],
            'password' => bcrypt($data['password'])
        ]);
    }
}
