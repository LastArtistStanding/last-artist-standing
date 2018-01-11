angular.module('users').factory('usersFactory', usersFactory);

usersFactory.$inject = ['LoginService'];

function usersFactory(LoginService) {
    return {
        index   : index
    };

    function index() {
        return LoginService.authRequest('GET', '/api/users')
            .then(function(data) {
                return data.data;
            });
    }
}