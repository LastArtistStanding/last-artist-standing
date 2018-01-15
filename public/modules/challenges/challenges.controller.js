angular.module('challenges')
    .controller('challengesController', challengesController)
    .controller('challengesModalController', challengesModalController);

challengesController.$inject = ['challengesFactory', '$uibModal', 'LoginService', '$scope'];

function challengesController(challengesFactory, $uibModal, LoginService, $scope) {
    var vm = this;

    vm.challenges = [];
    vm.isLoggedIn = false;

    vm.openNewChallengeModal = openNewChallengeModal;

    function activate() {
        getChallenges();
        isLoggedIn();
    }
    activate();

    $scope.$on('REFRESH', function(event, data) {
        isLoggedIn();
    });

    function isLoggedIn() {
        vm.isLoggedIn = LoginService.getMe() ? true : false;
    }

    function getChallenges() {
        challengesFactory.index()
            .then(function(data) {
                vm.challenges = setTimeLeft(data);
            });
    }

    function openNewChallengeModal() {
        $uibModal.open({
            animation: true,
            templateUrl: 'modules/challenges/challenges.post.html',
            controller: 'challengesModalController',
            controllerAs: 'vm',
            size: 'md'
        })
            .result.then(function(data) {
                data.created_at_readable = formatReadableDate(data.created_at);
                data = setTimeLeft([data])[data.status][0];
                vm.challenges[data.status].push(data);
            });
    }

    function setTimeLeft(challenges) {
        var sorted = {
            active: [],
            inactive: [],
            voting: []
        };
        angular.forEach(challenges, function(value, key) {
            if (value.status == 'active') {
                value.end_date_readable = calcDaysLeft(value.end_date);
            }
            value.created_at_readable = formatReadableDate(value.created_at);

            sorted[value.status].push(value);
        });

        return sorted;
    }
}

challengesModalController.$inject = ['$uibModalInstance', 'challengesFactory'];

function challengesModalController($uibModalInstance, challengesFactory) {
    var vm = this;

    vm.error = '';
    vm.challenge = {
        title: '',
        description: '',
        rules: '',
        contest: false,
        duration: null
    };

    vm.cancel = cancel;
    vm.save = save;
    vm.clearError = function() { vm.error = ''; };

    function cancel() {
        $uibModalInstance.dismiss();
    }

    function save() {
        challengesFactory.post(vm.challenge)
            .then(function(data) {
                $uibModalInstance.close(data);
            })
            .catch(function(error) {
                vm.error = error;
            });
    }
}