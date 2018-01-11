angular.module('stats', [])
    .controller('statsController', statsController);

statsController.$inject = ['LoginService'];

function statsController(LoginService) {
    var vm = this;

    vm.totalActivity = [];
    vm.mostSubmissions = [];
    vm.mostChallengeEntries = [];
    vm.mostCritReplies = [];
    vm.bestStreak = [];
    vm.error = '';

    vm.clearError = function() { vm.error = ''; };

    function activate() {
        getLists();
    }
    activate();

    function getLists() {
        LoginService.authRequest('GET', '/api/stats')
            .then(function(data) {
                data = data.data;

                vm.mostSubmissions = data.most_submissions;
                vm.mostChallengeEntries = data.most_challenge_entries;
                vm.mostCritReplies = data.most_crit_replies;
                vm.bestStreak = data.best_streak;
                vm.totalActivity = data.total_activity;
            })
            .catch(function(error) {
                vm.error = error;
            })
    }
}
