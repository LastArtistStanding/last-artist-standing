angular.module('critiques')
    .controller('critiqueController', CritiqueController);

CritiqueController.$inject = ['critiquesFactory', '$stateParams', '$state', 'LoginService', '$scope'];

function CritiqueController(critiquesFactory, $stateParams, $state, LoginService, $scope) {
    var vm = this;

    vm.critique = {};
    vm.newReply = {
        text: '',
        anonymous: false
    };
    vm.mine = false;
    vm.isLoggedIn = false;
    vm.hasResponded = false;
    vm.error = '';

    vm.post = post;
    vm.clearError = function() { vm.error = ''; };

    function activate() {
        getCritique();
        vm.isLoggedIn = LoginService.getAuthToken() ? true : false;
    }
    activate();

    $scope.$on('REFRESH', function(event, data) {
        var me = LoginService.getMe();
        if (me) {
            vm.mine = vm.critique.user_id == me.id;
        }

        vm.isLoggedIn = LoginService.getAuthToken() ? true : false;
    });

    function getCritique() {
        critiquesFactory.get($stateParams.id)
            .then(function(data) {
                vm.critique = data;
                vm.critique.created_at_readable = formatReadableDate(vm.critique.created_at);

                var me = LoginService.getMe();
                if (me) {
                    vm.mine = vm.critique.user_id == me.id;
                }

                angular.forEach(vm.critique.critique_replies, function(value, key) {
                    vm.critique.critique_replies[key].created_at_readable = formatReadableDate(value.created_at);
                    if (value.user_id == me.id) {
                        vm.hasResponded = true;
                    }
                });
            })
            .catch(function() {
                $state.go('critiques');
            })
    }

    function post() {
        if (vm.newReply.text.length > 0) {
            critiquesFactory.reply($stateParams.id, vm.newReply)
                .then(function(data) {
                    vm.critique.critique_replies.unshift(data);
                    vm.hasResponded = true;
                })
                .catch(function(error) {
                    vm.error = error;
                });
        }
    }

}