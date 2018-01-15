angular.module('submissions')
    .controller('submissionsController', submissionsController);

submissionsController.$inject = [
    'submissionsFactory', '$stateParams',
    '$state', '$scope', '$window', 'LoginService'
];

function submissionsController(
    submissionsFactory, $stateParams,
    $state, $scope, $window, LoginService
) {
    var vm = this;

    vm.submissions = [];
    vm.follow_submissions = [];
    vm.date = '';
    vm.offset = $stateParams.offset;
    vm.submissionCount = 0;
    vm.count = [];
    vm.nsfw = JSON.parse($window.localStorage.getItem('display_nsfw')) || false;
    vm.infoMode = JSON.parse($window.localStorage.getItem('submission_infomode')) || false;
    vm.followMode = false;
    vm.isLoggedIn = false;

    vm.graphData = [[]];
    vm.graphLabels = ['00:00', '01', '02', '03', '04', '05', '06', '07',
        '08', '09', '10', '11', '12:00', '13', '14', '15', '16', '17', '18', '19', '20', '21', '22', '23:00'];
    vm.chartOptions = {
        scales: {
            yAxes: [ {
                display: false
            } ],
            xAxes : [ {
                gridLines : {
                    display : false
                }
            } ]
        },
        tooltips: {
            enabled: false
        }
    };

    vm.navForth = navForth;
    vm.navBack = navBack;
    vm.isCurrentDate = isCurrentDate;
    vm.setNsfw = setNsfw;
    vm.toggleInfomode = toggleInfomode;
    vm.togglefollowMode = togglefollowMode;
    vm.follow = follow;

    function activate() {
        getSubmissions(vm.offset);
        getCount();
        checkLogin();
    }
    activate();

    $scope.$on('REFRESH', function(event, data) {
        if (data == 'submit') {
            activate();
        }
    });

    function sortFav(followedUsers) {
        // Put all follows back into main pool
        angular.forEach(vm.follow_submissions, function(value, key) {
            vm.submissions.push(value);
        });
        vm.follow_submissions = [];

        // Move submissions to followed list
        var submissions_moved = [];
        angular.forEach(vm.submissions, function(submission, key1) {
            angular.forEach(followedUsers, function(follow, key2) {
                if (submission.user.id == follow.target_user_id) {
                    vm.follow_submissions.push(submission);
                    submissions_moved.push(submission.id);
                }
            });
        });

        vm.submissions = vm.submissions.filter(function(submission) {
            return submissions_moved.indexOf(submission.id) == -1;
        })
    }

    function checkLogin() {
        var me = LoginService.getMe();
        vm.isLoggedIn = me ? true : false;
    }

    function follow(user_id) {
        submissionsFactory.follow(user_id).then(function(data) {
            sortFav(data);
        });
    }

    function getFollows() {
        submissionsFactory.follows().then(function(data) {
            sortFav(data);
        });
    }

    function getCount() {
        submissionsFactory.count().then(function(data) {
            angular.forEach(data, function(value, key) {
                data[key].created_at_readable = formatReadableDate(value.created_at);
            });

            vm.count = data;
        });
    }

    function togglefollowMode() {
        vm.followMode = !vm.followMode;
    }

    function toggleInfomode() {
        vm.infoMode = !vm.infoMode;
        $window.localStorage.setItem('submission_infomode', vm.infoMode);
    }

    function isCurrentDate(date) {
        if (vm.submissions.length > 0) {
            return vm.submissions[0].created_at.substring(0, 10) == date.substring(0, 10) ? 'active-block' : '';
        }
    }

    function getSubmissions(offset) {
        submissionsFactory.index(offset).then(function(data) {
            vm.submissions = data.data;
            getFollows();
            vm.submissionCount = vm.submissions.length;

            vm.submissions = addNsfwFilter(vm.submissions, vm.nsfw);

            var grouped_counts = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];
            angular.forEach(vm.submissions, function(value, key) {
                vm.submissions[key].created_at_readable = formatDateToTime(value.created_at);

                var hour = parseInt(value.created_at.substring(11, 13));
                grouped_counts[hour] += 1;
            });
            vm.graphData[0] = grouped_counts;

            if (vm.offset == 0) {
                vm.date = 'today';
            } else {
                if (vm.submissions.length > 0) {
                    vm.date = formatReadableDate(vm.submissions[0].created_at);
                } else {
                    // No submissions to grab date from so generate it
                    var today = new Date();
                    var day = new Date(today);
                    vm.date = formatReadableDate(day.setDate(today.getDate() - vm.offset));
                }
            }
        });
    }

    function setNsfw(bool) {
        vm.nsfw = bool;
        $window.localStorage.setItem('display_nsfw', vm.nsfw);
        vm.submissions = addNsfwFilter(vm.submissions, vm.nsfw);
        vm.follow_submissions = addNsfwFilter(vm.follow_submissions, vm.nsfw);
    }

    function navForth() {
        return $state.go('submissions', {offset: parseInt(vm.offset) - 1});
    }

    function navBack() {
        return $state.go('submissions', {offset: parseInt(vm.offset) + 1});
    }
}
