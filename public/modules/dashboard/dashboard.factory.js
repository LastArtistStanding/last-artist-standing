angular.module('dashboard').factory('dashboardFactory', dashboardFactory);

dashboardFactory.$inject = ['LoginService', '$q'];

function dashboardFactory(LoginService, $q) {
    return {
        getStreak       : getStreak,
        getStats        : getStats,
        getStreamers    : getStreamers
    };

    function getStreak() {
        return LoginService.authRequest('GET', '/api/streaks')
            .then(function(data) {
                return data.data;
            });
    }

    function getStats() {
        return LoginService.authRequest('GET', '/api/stats/dashboard')
            .then(function(data) {
                return data.data;
            });
    }

    function getStreamers() {
        return LoginService.authRequest('GET', '/api/stats/streamers', {ignoreLoadingBar: true})
            .then(function(data) {
                return data.data;
            });
    }
}