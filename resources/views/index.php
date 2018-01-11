<!doctype html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <title>DED</title>
    <base href="/" />

    <!-- TODO Download the font instead -->
    <link href="https://fonts.googleapis.com/css?family=Rubik" rel="stylesheet">

    <link rel="stylesheet" type="text/css" href="node_modules/bootstrap/dist/css/bootstrap.min.css">
    <link rel="stylesheet" type="text/css" href="node_modules/font-awesome/css/font-awesome.min.css">
    <link rel="stylesheet" type="text/css" href="node_modules/angular-loading-bar/build/loading-bar.min.css">
    <link rel="stylesheet" type="text/css" href="app.css">

    <!-- TODO Replace all includes with webpack loading -->
    <script src="node_modules/angular/angular.min.js"></script>
    <script src="node_modules/angular-animate/angular-animate.min.js"></script>
    <script src="node_modules/angular-sanitize/angular-sanitize.min.js"></script>
    <script src="node_modules/angular-loading-bar/build/loading-bar.min.js"></script>
    <script src="node_modules/angular-ui-bootstrap/dist/ui-bootstrap-tpls.js"></script>
    <script src="node_modules/angular-ui-router/release/angular-ui-router.min.js"></script>
    <script src="node_modules/chart.js/dist/Chart.min.js"></script>
    <script src="node_modules/angular-chart.js/dist/angular-chart.min.js"></script>

    <script src="modules/stats/stats.controller.js"></script>

    <script src="modules/profile/profile.controller.js"></script>

    <script src="modules/introduction/introduction.controller.js"></script>

    <script src="modules/feedback/feedback.controller.js"></script>

    <script src="modules/changelog/changelog.controller.js"></script>

    <script src="modules/challenges/challenges.module.js"></script>
    <script src="modules/challenges/challenges.factory.js"></script>
    <script src="modules/challenges/challenges.controller.js"></script>
    <script src="modules/challenge/challenge.controller.js"></script>

    <script src="modules/dashboard/dashboard.module.js"></script>
    <script src="modules/dashboard/dashboard.factory.js"></script>
    <script src="modules/dashboard/dashboard.controller.js"></script>

    <script src="modules/critiques/critiques.module.js"></script>
    <script src="modules/critiques/critiques.factory.js"></script>
    <script src="modules/critiques/critiques.controller.js"></script>
    <script src="modules/critique/critique.controller.js"></script>

    <script src="modules/users/users.module.js"></script>
    <script src="modules/users/users.factory.js"></script>
    <script src="modules/users/users.controller.js"></script>

    <script src="modules/submissions/submissions.module.js"></script>
    <script src="modules/submissions/submissions.factory.js"></script>
    <script src="modules/submissions/submissions.controller.js"></script>
    <script src="modules/submission/submission.controller.js"></script>

    <script src="modules/login/login.module.js"></script>
    <script src="modules/login/login.service.js"></script>
    <script src="modules/login/login.controller.js"></script>

    <script src="utils.js"></script>
    <script src="app.js"></script>
</head>

<body ng-app="app" ng-controller="sidebarController as vm">
    <div class="wrap">
        <div class="sidebar posFixed">
            <div class="sidebar-filler"></div>
            <div class="sidebar-inner">
                <div class="logo-container">
                    <img src="resources/logo.png" />
                </div>
                <ul>
                    <li ng-class="vm.active('dashboard')"><a ui-sref="dashboard"><i class="fa fa-font-awesome fa-fw"></i> Dashboard</a></li>
                    <li ng-class="vm.active('submissions')"><a ui-sref="submissions({offset: 0})"><i class="fa fa-picture-o fa-fw"></i> Submissions</a></li>
                    <li ng-class="vm.active('feedback')" ng-hide="!vm.isLoggedIn"><a ui-sref="feedback"><i class="fa fa-comment fa-fw"></i> Feedback</a></li>
                    <li ng-class="vm.active('critiques')"><a ui-sref="critiques"><i class="fa fa-comments fa-fw"></i> Critiques</a></li>
                    <li ng-class="vm.active('challenges')"><a ui-sref="challenges"><i class="fa fa-trophy fa-fw"></i> Challenges</a></li>
                    <li ng-class="vm.active('users')"><a ui-sref="users"><i class="fa fa-users fa-fw"></i> Users</a></li>
                    <li ng-class="vm.active('stats')"><a ui-sref="stats"><i class="fa fa-line-chart fa-fw"></i> Stats</a></li>

                    <li class="sidebar-divider"></li>

                    <li ng-class="vm.active('profile')" ng-hide="!vm.isLoggedIn"><a ui-sref="profile({id: vm.myId})"><i class="fa fa-user fa-fw"></i> Profile</a></li>
                    <li ng-hide="vm.isLoggedIn"><a ng-click="vm.login()"><i class="fa fa-sign-in fa-fw"></i> Login</a></li>
                    <li ng-hide="!vm.isLoggedIn"><a ng-click="vm.logout()"><i class="fa fa-sign-out fa-fw"></i> Logout</a></li>
                </ul>
            </div>
        </div>

        <div class="page container-fluid" ui-view></div>
    </div>

    <footer>
        <hr />
        <div class="content">
            <div class="col-md-4">Contact: w@doom.moe</div>
            <div class="col-md-4">A work in progress <br />
                <a href="https://github.com/LarsWalter/ded-progress" target="_blank">
                    <i class="fa fa-fw fa-github"></i>Want to help?
                </a>
            </div>
            <div class="col-md-4 footer"><a ui-sref="changelog"><i class="fa fa-check-square-o fa-fw"></i> Version {{ version }}</a></div>
        </div>
    </footer>

    <script>
        (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
                (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
            m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
        })(window,document,'script','https://www.google-analytics.com/analytics.js','ga');

        ga('create', 'CHANGEME', 'auto');
        ga('send', 'pageview');
    </script>
</body>