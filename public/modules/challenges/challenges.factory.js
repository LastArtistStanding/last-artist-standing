angular.module('challenges').factory('challengesFactory', challengesFactory);

challengesFactory.$inject = ['LoginService'];

function challengesFactory(LoginService) {
    return {
        index   : index,
        post    : post,
        active  : active,
        show    : show,
        getVote : getVote,
        vote    : vote,
        winner  : winner
    };

    function index() {
        return LoginService.authRequest('GET', '/api/challenges')
            .then(function(data) {
                return data.data;
            });
    }

    function show(id) {
        return LoginService.authRequest('GET', '/api/challenges/' + id)
            .then(function(data) {
                return data.data;
            });
    }

    function post(payload) {
        return LoginService.authRequest('POST', '/api/challenges', payload)
            .then(function(data) {
                return data.data;
            });
    }

    function active() {
        return LoginService.authRequest('GET', '/api/challenges/active')
            .then(function(data) {
                return data.data;
            });
    }

    function getVote(id) {
        return LoginService.authRequest('GET', '/api/challenges/' + id + '/my_vote')
            .then(function(data) {
                return data.data;
            });
    }

    function vote(id, payload) {
        return LoginService.authRequest('POST', '/api/challenges/' + id + '/vote', payload)
            .then(function(data) {
                return data.data;
            });
    }

    function winner(id) {
        return LoginService.authRequest('GET', '/api/challenges/' + id + '/winner')
            .then(function(data) {
                return data.data;
            });
    }
}