angular.module('profile', [])
    .controller('profileController', profileController)
    .directive('badge', badgeDirective)
    .controller('passwordPutController', passwordPutController);

profileController.$inject = ['$stateParams', 'LoginService', '$state', '$uibModal', '$window', '$scope'];

function profileController($stateParams, LoginService, $state, $uibModal, $window, $scope) {
    var vm = this;

    vm.userId = $stateParams.id;

    vm.user = {};
    vm.streakBadge = '';
    vm.badgeMode = true;
    vm.mine = false;
    vm.nsfw = JSON.parse($window.localStorage.getItem('display_nsfw')) || false;
    vm.selectedMonth = {};
    vm.submissions = [];
    vm.highlightMode = false;
    vm.error = '';

    vm.openPasswordModal = openPasswordModal;
    vm.setNsfw = setNsfw;
    vm.getSubmissionsFromMonth = getSubmissionsFromMonth;
    vm.toggleHighlightMode = toggleHighlightMode;
    vm.highlight = highlight;
    vm.unhighlight = unhighlight;
    vm.clearError = function() { vm.error = ''; };

    function active() {
        getUser();
    }
    active();

    $scope.$on('REFRESH', function(event, data) {
        var me = LoginService.getMe();
        if (me) {
            vm.mine = vm.user.id == me.id;
        } else {
            vm.mine = false;
        }
    });

    function unhighlight(id) {
        LoginService.authRequest('POST', 'api/unhighlight', {submission_id: id})
            .then(function() {
                vm.error = '';
                vm.user.highlights = vm.user.highlights.filter(function(value) {
                    return value.submission.id !== id;
                });
            })
            .catch(function(error) {
                vm.error = error;
            });
    }

    function highlight(id) {
        LoginService.authRequest('POST', 'api/highlight', {submission_id: id})
            .then(function(response) {
                vm.error = '';

                var time_period = formatDate(response.data.time_period);
                vm.user.highlights = vm.user.highlights.filter(function(value) {
                    return formatDate(value.time_period) !== time_period;
                });

                // TODO Check for response.data in highlight and replace object
                response.data = addNsfwFilter([response.data], vm.nsfw)[0];
                response.data.time_period_readable = formatYearMonthDate(response.data.time_period);
                vm.user.highlights.push(response.data);
            })
            .catch(function(error) {
                vm.error = error;
            });
    }

    function toggleHighlightMode() {
        vm.highlightMode = !vm.highlightMode;
    }

    function getUser() {
        LoginService.authRequest('GET', '/api/users/' + vm.userId)
            .then(function(data) {
                vm.user = data.data;

                var me = LoginService.getMe();
                if (me) {
                    vm.mine = vm.user.id == me.id;
                }

                if (!vm.user.streak) {
                    vm.user.streak = {current : 0};
                }

                vm.user.highlights = addNsfwFilter(vm.user.highlights, vm.nsfw);

                angular.forEach(vm.user.highlights, function(value, key) {
                    value.time_period_readable = formatYearMonthDate(value.time_period);
                });

                angular.forEach(vm.user.submission_counts, function(value, key) {
                    value.title = value.title + ' (' + value.count + ')';
                });
                vm.selectedMonth = vm.user.submission_counts[vm.user.submission_counts.length - 1];

                vm.user.created_at_readable = formatReadableDate(vm.user.created_at);
                vm.user = calcLastSeen([vm.user])[0];
                if (vm.user.streak) {
                    vm.streakBadge = setStreakBadge(vm.user.streak.best);
                }

                angular.forEach(vm.user.badges, function(value, key) {
                    vm.user.badges[key].created_at_readable = formatReadableDate(value.created_at);
                });

                angular.forEach(vm.user.locked_badges, function(value, key) {
                    vm.user.locked_badges[key] = {badge: value};
                });

                if (vm.selectedMonth) {
                    vm.getSubmissionsFromMonth();
                }
            })
            .catch(function() {
                $state.go('users');
            });
    }

    function getSubmissionsFromMonth() {
        var date = vm.selectedMonth.date;

        LoginService.authRequest('GET', '/api/users/' + vm.user.id + '/submissionsFromDate?date=' + date)
            .then(function(data) {
                vm.submissions = addNsfwFilter(data.data, vm.nsfw);
            });
    }

    function setNsfw(bool) {
        vm.nsfw = bool;
        $window.localStorage.setItem('display_nsfw', vm.nsfw);
        vm.user.submissions = addNsfwFilter(vm.submissions, vm.nsfw);
        vm.user.highlights = addNsfwFilter(vm.user.highlights, vm.nsfw);
    }

    function setStreakBadge(streak) {
        return 'resources/streaks/' + zeroPad(Math.floor(streak / 10) * 10, 5) + '.png';
    }

    function openPasswordModal() {
        $uibModal.open({
            animation: true,
            templateUrl: 'modules/profile/password.put.html',
            controller: 'passwordPutController',
            controllerAs: 'vm',
            size: 'md'
        })
    }
}

function badgeDirective() {
    return {
        restrict: 'E',
        template: '<img ng-class="data.created_at_readable ? \'\' : \'disabled-image\'" ng-src="resources/badges/{{data.badge.file_name}}"' +
        'uib-popover-template="badgePopoverTemplate"' +
        'popover-placement="bottom"' +
        'popover-trigger="\'mouseenter\'">',
        link: link,
        scope: {
            data: "="
        }
    };

    function link(scope, element, attrs) {
        scope.badgePopoverTemplate = 'modules/profile/badge-popover.html';
    }
}

passwordPutController.$inject = ['$uibModalInstance', 'LoginService'];

function passwordPutController($uibModalInstance, LoginService) {
    var vm = this;

    vm.passwords = {
        password: '',
        new_password: '',
        new_password_confirmation: ''
    };
    vm.error = '';

    vm.save = save;
    vm.cancel = cancel;
    vm.clearError = function() { vm.error = ''; };

    function save() {
        LoginService.authRequest('PUT', 'api/password', vm.passwords)
            .then(function() {
                $uibModalInstance.close();
            })
            .catch(function(error) {
                vm.error = error;
            })
    }

    function cancel() {
        $uibModalInstance.dismiss();
    }
}
