angular
    .module('app', ['ui.router', 'ui.bootstrap', 'ngAnimate', 'angular-loading-bar', 'ngSanitize', 'chart.js',
        'login', 'dashboard', 'stats', 'submissions', 'users', 'changelog', 'profile', 'critiques', 'challenges', 'introduction', 'feedback'])
    .config(routesConfig)
    .config(['cfpLoadingBarProvider', function(cfpLoadingBarProvider) {
        cfpLoadingBarProvider.includeSpinner = false;
    }])
    .run(routeRun)
    .controller('sidebarController', sidebarController);

/**
 * REFRESH broadcast events:
 * submit, register, login, logout
 */

routesConfig.$inject = ['$stateProvider', '$urlRouterProvider', '$locationProvider'];

function routesConfig($stateProvider, $urlRouterProvider, $locationProvider) {
    $locationProvider.html5Mode(true).hashPrefix('!');
    $urlRouterProvider.otherwise('404');

    [
        {
            name: 'dashboard',
            data: {
                url: '/',
                title: 'Dashboard',
                templateUrl: 'modules/dashboard/dashboard.html',
                controller: 'dashboardController',
                controllerAs: 'vm'
            }
        },
        {
            name: 'feedback',
            data: {
                url: '/feedback',
                title: 'Feedback',
                templateUrl: 'modules/feedback/feedback.html',
                controller: 'feedbackController',
                controllerAs: 'vm'
            }
        },
        {
            name: 'profileEMPTY',
            data: {
                url: '/profile',
                redirectTo: 'users'
            }
        },
        {
            name: 'profile',
            data: {
                url: '/profile/:id',
                title: 'Profile',
                templateUrl: 'modules/profile/profile.html',
                controller: 'profileController',
                controllerAs: 'vm'
            }
        },
        {
            name: 'stats',
            data: {
                url: '/stats',
                title: 'Stats',
                templateUrl: 'modules/stats/stats.html',
                controller: 'statsController',
                controllerAs: 'vm'
            }
        },
        {
            name: 'users',
            data: {
                url: '/users',
                title: 'Users',
                templateUrl: 'modules/users/users.html',
                controller: 'usersController',
                controllerAs: 'vm'
            }
        },
        {
            name: 'userEMPTY',
            data: {
                url: '/user',
                redirectTo: 'users'
            }
        },
        {
            name: 'submissionsEMPTY',
            data: {
                url: '/submissions',
                redirectTo: 'submissions',
                params: {offset: 0}
            }
        },
        {
            name: 'submissions',
            data: {
                url: '/submissions/:offset',
                title: 'Submissions',
                templateUrl: 'modules/submissions/submissions.html',
                controller: 'submissionsController',
                controllerAs: 'vm'
            }
        },
        {
            name: 'submissionEMPTY',
            data: {
                url: '/submission',
                redirectTo: 'submissions'
            }
        },
        {
            name: 'submission',
            data: {
                url: '/submission/:id',
                title: 'Submission',
                templateUrl: 'modules/submission/submission.html',
                controller: 'submissionController',
                controllerAs: 'vm'
            }
        },
        {
            name: 'critiques',
            data: {
                url: '/critiques',
                title: 'Critiques',
                templateUrl: 'modules/critiques/critiques.html',
                controller: 'critiquesController',
                controllerAs: 'vm'
            }
        },
        {
            name: 'critique',
            data: {
                url: '/critique/:id',
                title: 'Critique',
                templateUrl: 'modules/critique/critique.html',
                controller: 'critiqueController',
                controllerAs: 'vm'
            }
        },
        {
            name: 'critiqueEMPTY',
            data: {
                url: '/critique',
                redirectTo: 'critiques'
            }
        },
        {
            name: 'challenges',
            data: {
                url: '/challenges',
                title: 'Challenges',
                templateUrl: 'modules/challenges/challenges.html',
                controller: 'challengesController',
                controllerAs: 'vm'
            }
        },
        {
            name: 'challenge',
            data: {
                url: '/challenge/:id',
                title: 'Challenge',
                templateUrl: 'modules/challenge/challenge.html',
                controller: 'challengeController',
                controllerAs: 'vm'
            }
        },
        {
            name: 'challengeEMPTY',
            data: {
                url: '/challenge',
                redirectTo: 'challenges'
            }
        },
        {
            name: 'changelog',
            data: {
                url: '/changelog',
                title: 'Changelog',
                templateUrl: 'modules/changelog/changelog.html',
                controller: 'changelogController',
                controllerAs: 'vm'
            }
        },
        {
            name: 'introduction',
            data: {
                url: '/introduction',
                title: 'Introduction',
                templateUrl: 'modules/introduction/introduction.html',
                controller: 'introductionController',
                controllerAs: 'vm'
            }
        },
        {
            name: '404',
            data: {
                url: '/404',
                title: '404',
                templateUrl: 'modules/notFound/404.html'
            }
        }

    ].forEach(function(state) { $stateProvider.state(state.name, state.data); });
}

routeRun.$inject = ['$rootScope', '$state', '$window'];

function routeRun($rootScope, $state, $window) {
    $rootScope.version = 0.2;

    $rootScope.$on('$stateChangeStart', function(evt, to, params) {

        if (to.title) {
            $window.document.title = 'DED - ' + to.title;
        }

        if (to.name != 'introduction' && !$window.localStorage.getItem('hide_intro')) {
            evt.preventDefault();
            $state.go('introduction');
        } else if (to.name == 'feedback') {
            var me = $window.localStorage.getItem('me');
            if (!me) {
                evt.preventDefault();
                $state.go('dashboard');
            }
        } else if (to.redirectTo) {
            evt.preventDefault();
            if (to.params) {
                $state.go(to.redirectTo, to.params, { location: 'replace' });
            } else {
                $state.go(to.redirectTo, params, { location: 'replace' });
            }
        }
    });
}

sidebarController.$inject = ['$state', 'LoginService', '$uibModal', '$scope'];

function sidebarController($state, LoginService, $uibModal, $scope) {
    var vm = this;

    vm.login = login;
    vm.logout = logout;
    vm.active = active;
    vm.goToProfile = goToProfile;

    vm.isLoggedIn = false;
    vm.myId = 0;

    function activate() {
        vm.isLoggedIn = loggedIn();
    }
    activate();

    $scope.$on('REFRESH', function(event, data) {
        activate();
    });

    function loggedIn() {
        var isLoggedIn = LoginService.getAuthToken() ? true : false;
        if (isLoggedIn) {
            vm.myId = LoginService.getMe().id;
        }
        return isLoggedIn;
    }

    function goToProfile() {
        $state.go('profile', {id: LoginService.getMe().id});
    }

    function login() {
        $uibModal.open({
            animation: true,
            templateUrl: 'modules/login/login.modal.html',
            controller: 'loginController',
            controllerAs: 'vm',
            size: 'sm'
        });
    }

    function logout() {
        LoginService.logout();
    }

    function active(route) {
        return $state.current.name === route ? 'active' : '';
    }
}