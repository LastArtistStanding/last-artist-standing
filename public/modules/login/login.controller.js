angular.module('login')
    .controller('loginController', loginController);

loginController.$inject = ['LoginService', '$uibModalInstance'];

function loginController(LoginService, $uibModalInstance) {
    var vm = this;

    vm.registerMode = false;
    vm.error = '';
    vm.registerData = {};
    vm.loginData = {};

    vm.login = login;
    vm.register = register;
    vm.toggleRegisterMode = toggleRegisterMode;
    vm.clearError = function() { vm.error = ''; };

    function register() {
        if (!vm.registerData.username) {
            vm.error = 'Missing username.';
            return;
        }
        if (!vm.registerData.password) {
            vm.error = 'Missing password.';
            return;
        }
        if (!vm.registerData.password_confirmation) {
            vm.error = 'Missing password confirmation.';
            return;
        }
        if (vm.registerData.password !== vm.registerData.password_confirmation) {
            vm.error = 'Passwords don\'t match.';
            return;
        }

        LoginService.register(vm.registerData)
            .then(function() {
                $uibModalInstance.close();
            })
            .catch(function(data) {
                vm.error = data.data.error.join();
            });
    }

    function toggleRegisterMode() {
        vm.registerMode = !vm.registerMode;
    }

    function login() {
        if (!vm.loginData.username) {
            vm.error = 'Missing username.';
            return;
        }
        if (!vm.loginData.password) {
            vm.error = 'Missing password.';
            return;
        }

        LoginService.login(vm.loginData)
            .then(function() {
                $uibModalInstance.close();
            })
            .catch(function(data) {
                vm.error = data.data.error.join();
            });
    }

}
