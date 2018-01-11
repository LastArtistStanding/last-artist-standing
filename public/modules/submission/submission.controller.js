angular.module('submissions')
    .controller('submissionController', submissionController)
    .controller('submissionPutController', submissionPutController)
    .controller('redlinePostController', redlinePostController);

submissionController.$inject = ['$stateParams', '$state', 'LoginService', '$window', '$uibModal', '$scope'];

function submissionController($stateParams, $state, LoginService, $window, $uibModal, $scope) {
    var vm = this;
    var submissionId = $stateParams.id;

    vm.submission = {};
    vm.submissions = [];
    vm.mine = false;
    vm.nsfw = JSON.parse($window.localStorage.getItem('display_nsfw')) || false;
    vm.isLoggedIn = false;

    vm.openEditModal = openEditModal;
    vm.setNsfw = setNsfw;
    vm.openRedlineModal = openRedlineModal;

    function activate() {
        getSubmission();
    }
    activate();

    $scope.$on('REFRESH', function(event, data) {
        activate(); // Need to refresh to get redlines if relevant
    });

    // TODO Move requests into factory
    function getSubmission() {
        LoginService.authRequest('GET', 'api/submissions/' + submissionId)
            .then(function(data) {
                vm.submission = data.data;
                vm.image = vm.submission.imagePath;
                //vm.image = 'http://' + $window.location.hostname + '/api/submissions/' + submissionId + '/image';
                vm.submission.created_at_readable = formatReadableDateWithTime(vm.submission.created_at);

                var me = LoginService.getMe();
                if (me) {
                    vm.isLoggedIn = true;
                    vm.mine = me.id == vm.submission.user.id;
                } else {
                    vm.isLoggedIn = false;
                }

                setChallengeText();
                getSubmissions();
            })
            .catch(function() {
                $state.go('submissions');
            });
    }

    function setChallengeText() {
        if (vm.submission.challenge_entries.length > 0) {
            if (vm.submission.challenge_entries.length == 1) {
                vm.submission.challenge_status = 'Entered into the \''+ vm.submission.challenge_entries[0].challenge.title +'\' challenge!'
            } else {
                var challengeNames = '';
                angular.forEach(vm.submission.challenge_entries, function(value, key) {
                    challengeNames += value.challenge.title + ', ';
                });
                challengeNames = challengeNames.slice(0, -2);
                vm.submission.challenge_status = 'Entered into several challenges: ' + challengeNames + '!';
            }
        } else {
            vm.submission.challenge_status = 'Not part of a challenge.'
        }
    }

    function getSubmissions() {
        LoginService.authRequest('GET', 'api/users/' + vm.submission.user_id + '/submissions?limit=12')
            .then(function(data) {
                vm.submissions = data.data.submissions;
                addNsfwFilter(vm.submissions, vm.nsfw);
            });
    }

    function setNsfw(bool) {
        vm.nsfw = bool;
        $window.localStorage.setItem('display_nsfw', vm.nsfw);
        vm.submissions = addNsfwFilter(vm.submissions, vm.nsfw);
    }

    function openRedlineModal() {
        $uibModal.open({
            animation: true,
            templateUrl: 'modules/submission/redline.post.html',
            controller: 'redlinePostController',
            controllerAs: 'vm',
            size: 'md',
            resolve: {
                submission_id: function() {
                    return vm.submission.id;
                }
            }
        })
            .result.then(function(data) {
            vm.submission.redlines = data;
        })
    }

    function openEditModal() {
        $uibModal.open({
            animation: true,
            templateUrl: 'modules/submission/submission.put.html',
            controller: 'submissionPutController',
            controllerAs: 'vm',
            size: 'md',
            resolve: {
                submission: function() {
                    return JSON.stringify(vm.submission);
                }
            }
        })
            .result.then(function(data) {
                if (data != 'deleted') {
                    vm.submission = data;
                    setChallengeText();
                } else {
                    $state.go('submissions', {offset: 0});
                }
        })
    }
}

submissionPutController.$inject = ['submission', '$uibModalInstance', 'LoginService'];

function submissionPutController(submission, $uibModalInstance, LoginService) {
    var vm = this;

    vm.submission = JSON.parse(submission);

    vm.save = save;
    vm.deleteSubmission = deleteSubmission;
    vm.cancel = cancel;

    function save() {
        LoginService.authRequest('PUT', 'api/submissions/' + vm.submission.id, vm.submission)
            .then(function(data) {
                $uibModalInstance.close(data.data);
            });
    }

    function deleteSubmission() {
        LoginService.authRequest('DELETE', 'api/submissions/' + vm.submission.id)
            .then(function() {
                $uibModalInstance.close('deleted');
            });
    }

    function cancel() {
        $uibModalInstance.dismiss();
    }
}

redlinePostController.$inject = ['submission_id', '$uibModalInstance', 'LoginService'];

function redlinePostController(submission_id, $uibModalInstance, LoginService) {
    var vm = this;

    vm.error = '';

    vm.save = save;
    vm.cancel = cancel;
    vm.clearError = function() { vm.error = ''; };

    function save() {
        LoginService.authRequest('POST', 'api/submissions/' + submission_id + '/redline', vm.redline)
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