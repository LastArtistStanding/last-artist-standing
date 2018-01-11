angular.module('changelog', [])
    .controller('changelogController', changelogController);

changelogController.$inject = [];

function changelogController() {
    var vm = this;

    vm.plans = [
        'Site statistics',
        'Personal statistics',
        'Build task for frontend',
        'Continious onslaught of adding more badges',
        'highlight new challenges, critiques, feedback on dashboard',
        'Followed users daily status on dashboard',
        'Work on branding the website',
        'Change challenge entries leaderboard to days submitted to challenges'
    ];

    vm.changelog = [
        {v: 0.2, features: ['Started 06.10.16',
            'Fixed long load time on dashboard',
            'Drawing suggestions on the dashboard',
            'Feedback list',
            'Show title and timestamp on challenge entries',
            'Time graph on submissions page',
            'Can follow users on submissions page',
            'Can enter one submission into several challenges',
            'Paginated userlist',
            'Streak badges from Overwatch'
        ]},
        {v: 0.1, features: ['Initial development - Released 01.10.16',
            'Submissions',
            'Personal submission highlights',
            'Redline / feedback',
            'Critiques',
            'Challenges',
            'Basic leaderboards',
            'Stream checker',
            'Badge system',
            'Badges: Submission counts, Minimalist, Double Down, Speedster, Daredevil'
        ]}
    ]
}
