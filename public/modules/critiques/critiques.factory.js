angular.module('critiques').factory('critiquesFactory', critiquesFactory);

critiquesFactory.$inject = ['LoginService'];

function critiquesFactory(LoginService) {
    return {
        index           : index,
        get             : get,
        store           : store,
        getMyReplies    : getMyReplies,
        reply           : reply
    };

    function index() {
        return LoginService.authRequest('GET', '/api/critiques')
            .then(function(data) {
                return data.data;
            });
    }

    function get(id) {
        return LoginService.authRequest('GET', '/api/critiques/' + id)
            .then(function(data) {
                return data.data;
            });
    }

    function store(payload) {
        return LoginService.authRequest('POST', '/api/critiques', payload)
            .then(function(data) {
                return data.data;
            });
    }

    function getMyReplies() {
        return LoginService.authRequest('GET', '/api/critiques/my/replies')
            .then(function(data) {
                return data.data;
            });
    }

    function reply(id, payload) {
        return LoginService.authRequest('POST', '/api/critiques/' + id, payload)
            .then(function(data) {
                return data.data;
            });
    }
}