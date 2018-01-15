angular.module('users')
    .controller('usersController', usersController);

usersController.$inject = ['usersFactory', '$scope'];

function usersController(usersFactory, $scope) {
    var vm = this;

    vm.orderString = 'last_seen_hours';
    vm.users = [];
    vm.paginated = [];
    vm.selectedChunk = 0;

    vm.setOrderString = setOrderString;
    vm.selectChunk = selectChunk;

    function activate() {
        getUsers()
    }
    activate();

    $scope.$on('REFRESH', function(event, data) {
        if (data == 'register') {
            activate();
        }
    });

    function selectChunk(key) {
        vm.selectedChunk = key;
    }

    function getUsers() {
        usersFactory.index()
            .then(function(data) {
                vm.users = calcLastSeen(data);
                vm.paginated = paginate(vm.users, 15, vm.orderString, false);
            });
    }

    function setOrderString(string) {
        var descending = false;
        if (vm.orderString == string) {
            vm.orderString = '-' + string;
            descending = true;
        } else {
            vm.orderString = string;
        }

        vm.paginated = paginate(vm.users, 15, string, descending);
    }

    function paginate(users, chunkSize, orderString, descending) {
        users.sort(function(a, b) {
            if (orderString == 'last_seen_hours') {
                return descending ?
                    b[orderString] - a[orderString] :
                    a[orderString] - b[orderString];
            } else if (orderString == 'username') {
                return descending ?
                    b[orderString].localeCompare(a[orderString]) :
                    a[orderString].localeCompare(b[orderString]);
            } else if (orderString == 'created_at') {
                var date1 = new Date(a.created_at);
                var date2 = new Date(b.created_at);
                if (descending) {
                    if (date1 > date2) return -1;
                    if (date1 < date2) return 1;
                } else {
                    if (date1 > date2) return 1;
                    if (date1 < date2) return -1;
                }
            } else {
                return 0;
            }
        });

        var chunks = [],
            i = 0,
            n = users.length;

        while (i < n) {
            chunks.push(users.slice(i, i += chunkSize));
        }

        return chunks;
    }
}