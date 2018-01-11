angular.module('critiques')
    .controller('critiquesController', critiquesController);

critiquesController.$inject = ['critiquesFactory', '$scope', 'LoginService'];

function critiquesController(critiquesFactory, $scope, LoginService) {
    var vm = this;

    vm.critiques = {
        active: [],
        inactive: []
    };
    vm.newCritique = {
        allow_anonymous: true,
        description: ''
    };
    vm.replies = [];
    vm.haveCritique = false;
    vm.isLoggedIn = false;
    vm.error = '';

    vm.askForCritique = askForCritique;
    vm.clearError = function() { vm.error = ''; };

    function activate() {
        getCritiques();
        checkLogin();
    }
    activate();

    $scope.$on('REFRESH', function(event, data) {
        checkLogin();
    });

    function checkLogin() {
        vm.isLoggedIn = LoginService.getAuthToken() ? true : false;
        if (vm.isLoggedIn) {
            getreplies();
        }
    }

    function getreplies() {
        critiquesFactory.getMyReplies()
            .then(function(data) {
                if (data.length > 0) {
                    vm.replies = data;
                    vm.haveCritique = true;
                }
            });
    }

    function getCritiques() {
        critiquesFactory.index()
            .then(function(data) {
                sortCritiques(data);
            });
    }

    function askForCritique() {
        critiquesFactory.store(vm.newCritique)
            .then(function(data) {
                vm.critiques[data.status].push(data);
                vm.haveCritique = true;
            })
            .catch(function(error) {
                vm.error = error;
            })
    }

    function sortCritiques(data) {
        if (vm.isLoggedIn) {
            var myName = LoginService.getMe().username;
        }

        angular.forEach(data, function(value, key) {
            if (vm.isLoggedIn && value.username == myName && value.status == 'active') {
                vm.haveCritique = true;
            }

            vm.critiques[value.status].push(value);
        });
    }
}