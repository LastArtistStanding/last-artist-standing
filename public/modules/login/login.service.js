angular.module('login')
    .service('LoginService', LoginService);

LoginService.$inject = ['$http', '$window', '$q', '$interval', '$rootScope'];

function LoginService($http, $window, $q, $interval, $rootScope) {
    var requestingToken = false;

    return {
        getAuthToken    : getAuthToken,
        setAuthToken    : setAuthToken,
        getMe           : getMe,
        setMe           : setMe,
        authRequest     : authRequest,
        requestNewToken : requestNewToken,
        login           : login,
        logout          : logout,
        register        : register
    };

    function register(payload) {
        return $http({
            method: 'POST',
            url: '/api/register',
            data: payload
        })
            .then(function(data) {
                setAuthToken(data.data.token);
                setMe(data.data.user);
                $rootScope.$broadcast('REFRESH', 'register');
            });
    }

    function login(payload) {
        return $http({
            method: 'POST',
            url: '/api/login',
            data: payload
        })
            .then(function(data) {
                setAuthToken(data.data.token);
                setMe(data.data.user);
                $rootScope.$broadcast('REFRESH', 'login');
            });
    }

    function logout() {
        return authRequest('GET', '/api/logout')
            .then(function() {
                $window.localStorage.removeItem('authToken');
                $window.localStorage.removeItem('me');
                $rootScope.$broadcast('REFRESH', 'logout');
            });
    }

    function getMe() {
        var me = $window.localStorage.getItem('me');
        if (me) {
            return JSON.parse(me);
        }
        else return null;
    }

    function setMe(user) {
        if (user) {
            $window.localStorage.setItem('me', JSON.stringify(user));
        }
    }

    function getAuthToken() {
        return $window.localStorage.getItem('authToken');
    }

    function setAuthToken(token) {
        if (token) {
            $window.localStorage.setItem('authToken', token);
        }
    }

    function authRequest(method, url, data) {
        var q = $q.defer();

        var showLoading = false;
        if (data && data.ignoreLoadingBar) {
            showLoading = true;
        }
        if (!getAuthToken()) {
            return $http({
                method: method,
                url: url,
                data: data,
                ignoreLoadingBar: showLoading
            });
        } else {
            $http({
                method: method,
                url: url,
                data: data,
                headers: { 'Authorization': 'Bearer ' + getAuthToken() },
                ignoreLoadingBar: showLoading
            })
                .then(function(response) {
                    q.resolve(response);
                })
                .catch(function(response) {
                    if (response.data && response.data.hasOwnProperty('error') && (response.data.error == 'token_expired')) { // Token needs refreshing
                        requestNewToken()
                            .then(function() {
                                $http({
                                    method: method,
                                    url: url,
                                    data: data,
                                    headers: { 'Authorization': 'Bearer ' + getAuthToken() }
                                })
                                    .then(function(response) {
                                        q.resolve(response);
                                    })
                                    .catch(function(response) {
                                        q.reject(response); // Failed request after updated token
                                    });
                            })
                            .catch(function(response) {
                                q.reject(response); // Failed to refresh token
                            });
                    } else {
                        if (response.data && response.data.hasOwnProperty('error') && (response.data.error == 'token_invalid')) { // Fake or broken token
                            $window.localStorage.removeItem('authToken');
                            $window.localStorage.removeItem('me');
                            q.reject(response);
                        } else if (response.data && response.data.hasOwnProperty('error')) {
                            q.reject(response.data.error.join());
                        } else {
                            q.reject(response);
                        }
                    }
                });

        }

        return q.promise;
    }

    function requestNewToken() {
        var q = $q.defer();

        // Already requesting token, wait for 5 second waiting on the refreshed token
        if (this.requestingToken) {
            var currentLoop = 0;
            var waiter = $interval(function() {
                    if (!requestingToken) {
                        $interval.cancel(waiter);
                        q.resolve();
                    }

                    if (currentLoop++ > 11) { // 5 second max wait
                        $interval.cancel(waiter);
                        q.reject(); // Failed to get token in time
                    }
                }, 500);
        } else {
            this.requestingToken = true;

            $http({
                method: 'GET',
                url: 'api/refresh_token',
                headers: { 'Authorization': 'Bearer ' + getAuthToken() }
            })
                .then(function(response) {
                    setAuthToken(response.data.token);
                    requestingToken = false;
                    q.resolve();
                })
                .catch(function() {
                    q.reject();
                });
        }

        return q.promise;
    }
}