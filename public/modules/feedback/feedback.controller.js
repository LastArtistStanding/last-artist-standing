angular.module('feedback', [])
    .controller('feedbackController', feedbackController);

feedbackController.$inject = ['LoginService', '$scope', '$state'];

function feedbackController(LoginService, $scope, $state) {
    var vm = this;

    vm.feedback = [];

    vm.clearError = function() { vm.error = ''; };

    function activate() {
        getFeedback();
    }
    activate();

    $scope.$on('REFRESH', function(event, data) {
        if (data === 'logout') {
            $state.go('dashboard');
        } else {
            activate();
        }
    });

    function getFeedback() {
        LoginService.authRequest('GET', 'api/feedback')
            .then(function(response) {
                vm.error = '';
                vm.feedback = response.data;

                angular.forEach(vm.feedback, function(value, key) {
                    vm.feedback[key].created_at_readable = formatReadableDate(value.created_at);
                });
            })
            .catch(function(error) {
                vm.error = error;
            })
    }

    function formatDates() {

    }
}
