angular.module('challenges')
    .controller('challengeController', challengeController)
    .controller('challengePutController', challengePutController);

challengeController.$inject = ['challengesFactory', '$stateParams', 'LoginService',
    '$scope', '$uibModal', '$window'];

function challengeController(challengesFactory, $stateParams, LoginService,
                             $scope, $uibModal, $window) {
    var vm = this;

    vm.challenge = {};
    vm.isLoggedIn = false;
    vm.myVote = {};
    vm.error = '';
    vm.mine = false;
    vm.nsfw = JSON.parse($window.localStorage.getItem('display_nsfw')) || false;

    vm.vote = vote;
    vm.clearError = function() { vm.error = ''; };
    vm.openEditModal = openEditModal;
    vm.setNsfw = setNsfw;

    function activate() {
        getChallenge();
        isLoggedIn();
    }
    activate();

    $scope.$on('REFRESH', function(event, data) {
        isLoggedIn();

        var me = LoginService.getMe();
        if (me) {
            vm.mine = me.id == vm.challenge.user.id;
        }
    });

    function setNsfw(bool) {
        vm.nsfw = bool;
        $window.localStorage.setItem('display_nsfw', vm.nsfw);
        vm.challenge.entries = addNsfwFilter(vm.challenge.entries, vm.nsfw);
    }

    function getMyVote() {
        challengesFactory.getVote($stateParams.id)
            .then(function(data) {
                vm.myVote = data;
            });
    }

    function getWinner() {
        challengesFactory.winner($stateParams.id)
            .then(function(data) {
                vm.winner = data;
            });
    }

    function vote(entry) {
        var payload = {
            entry_id: entry.id
        };

        challengesFactory.vote($stateParams.id, payload)
            .then(function(data) {
                vm.myVote = data;
            })
            .catch(function(error) {
                vm.error = error;
            })
    }

    function isLoggedIn() {
        vm.isLoggedIn = LoginService.getMe() ? true : false;
    }

    function getChallenge() {
        challengesFactory.show($stateParams.id)
            .then(function(data) {
                data.entry_count = data.entries.length;
                data.rules = JSON.parse(data.rules);
                data.end_date_readable = calcDaysLeft(data.end_date);
                vm.challenge = data;

                vm.challenge.entries = addNsfwFilter(vm.challenge.entries, vm.nsfw);
                vm.challenge.entries = groupUsers(vm.challenge.entries);

                var me = LoginService.getMe();
                if (me) {
                    vm.mine = me.id == vm.challenge.user.id;
                }

                if (vm.challenge.status == 'voting') {
                    getMyVote();
                } else if (vm.challenge.status == 'inactive' && vm.challenge.contest) {
                    getWinner();
                }
            });
    }

    function groupUsers(submissions) {
        var users = {};

        angular.forEach(submissions, function(value, key) {
            var username = value.user.username;
            if (!users[username]) {
                users[username] = [];
            }
            users[username].push(value);
        });

        submissions = [];
        angular.forEach(users, function(value, key) {
            angular.forEach(value, function(value2, key2) {
                value2.created_at_readable = formatReadableDate(value2.created_at);
                submissions.push(value2);
            });
        });

        return submissions;
    }

    function openEditModal() {
        $uibModal.open({
            animation: true,
            templateUrl: 'modules/challenge/challenge.put.html',
            controller: 'challengePutController',
            controllerAs: 'vm',
            size: 'md',
            resolve: {
                challenge: function() {
                    return JSON.stringify(vm.challenge);
                }
            }
        })
            .result.then(function(data) {
                vm.challenge.title = data.title;
                vm.challenge.description = data.description;
                vm.challenge.rules = JSON.parse(data.rules);
            });
    }
}

challengePutController.$inject = ['challenge', '$uibModalInstance', 'LoginService'];

function challengePutController(challenge, $uibModalInstance, LoginService) {
    var vm = this;

    vm.challenge = JSON.parse(challenge);
    vm.error = '';

    vm.save = save;
    vm.cancel = cancel;
    vm.clearError = function() { vm.error = ''; };


    function activate() {
        vm.challenge.rules = vm.challenge.rules.join('\n');
    }
    activate();

    function save() {
        LoginService.authRequest('PUT', 'api/challenges/' + vm.challenge.id, vm.challenge)
            .then(function(data) {
                $uibModalInstance.close(data.data);
            })
            .catch(function(error) {
                vm.error = error;
            });
    }

    function cancel() {
        $uibModalInstance.dismiss();
    }
}
