angular.module('introduction', [])
    .controller('introductionController', introductionController);

introductionController.$inject = ['$window', '$state'];

function introductionController($window, $state) {
    var vm = this;

    vm.enter = enter;

    function enter() {
        $window.localStorage.setItem('hide_intro', 1);
        $state.go('dashboard');
    }
}
