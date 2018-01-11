angular.module('submissions').factory('submissionsFactory', submissionsFactory);

submissionsFactory.$inject = ['LoginService', '$q', '$rootScope'];

function submissionsFactory(LoginService, $q, $rootScope) {
    return {
        index   : index,
        follow : follow,
        follows : follows,
        destroy : destroy,
        newest  : newest,
        post    : post,
        count   : count
    };

    function index(offset) {
        return LoginService.authRequest('GET', '/api/submissions/offset/' + offset);
    }

    function follows() {
        var q = $q.defer();

        var me = LoginService.getMe();
        if (me) {
            LoginService.authRequest('GET', 'api/follows')
                .then(function(data) {
                    q.resolve(data.data);
                })
                .catch(function() {
                    q.reject();
                })
        } else {
            q.reject();
        }

        return q.promise;
    }

    function follow(user_id) {
        var q = $q.defer();

        var me = LoginService.getMe();
        if (me) {
            LoginService.authRequest('PUT', 'api/follows', {user_id: user_id})
                .then(function(data) {
                    q.resolve(data.data);
                })
                .catch(function() {
                    q.reject();
                })
        } else {
            q.reject();
        }

        return q.promise;
    }

    function post(data) {
        return LoginService.authRequest('POST', 'api/submissions', data)
            .then(function() {
                $rootScope.$broadcast('REFRESH', 'submit');
            });
    }

    function count() {
        return LoginService.authRequest('GET', 'api/submissions/count')
            .then(function(data) {
                return data.data;
            });
    }

    function newest() {
        return LoginService.authRequest('GET', '/api/submissions/newest')
            .then(function(data) {
                return data.data;
            });
    }

    function destroy(id) {
        return LoginService.authRequest('DELETE', '/api/comments/' + id);
    }
}