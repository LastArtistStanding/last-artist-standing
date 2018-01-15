function formatDate(date) {
    var object = new Date(date);
    var month = object.getMonth() + 1;
    return zeroPad(object.getHours(), 2) + ':' +
        zeroPad(object.getMinutes(), 2) + ':' +
        zeroPad(object.getSeconds(), 2) + ' ' +
        zeroPad(object.getDate(), 2) +  '/' +
        zeroPad(month, 2) + '/' +
        object.getFullYear();
}

function formatDateToTime(date) {
    return date.substring(10, 19);
}

function formatReadableDate(date) {
    var object = new Date(date);
    var monthNames = ["January", "February", "March", "April", "May", "June",
        "July", "August", "September", "October", "November", "December"];

    return object.getDate() +  '. ' + monthNames[object.getMonth()] + ' ' + object.getFullYear();
}

function formatReadableDateWithTime(date) {
    var object = new Date(date);
    var monthNames = ["January", "February", "March", "April", "May", "June",
        "July", "August", "September", "October", "November", "December"];

    return object.getDate() +  '. ' + monthNames[object.getMonth()] + ' ' + object.getFullYear() +
            ' ' + zeroPad(object.getHours(), 2) + ':' + zeroPad(object.getMinutes(), 2) + ':' + zeroPad(object.getSeconds(), 2);
}

function formatYearMonthDate(date) {
    var object = new Date(date);
    var monthNames = ["January", "February", "March", "April", "May", "June",
        "July", "August", "September", "October", "November", "December"];

    return monthNames[object.getMonth()] + ' ' + object.getFullYear();
}

function zeroPad(value, len) {
    var s = "00000" + value;
    return s.substr(s.length-len);
}

function calcLastSeen(users) {
    angular.forEach(users, function(value, key) {

        var now = new Date();
        var now_date = new Date(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate(),
            now.getUTCHours(), now.getUTCMinutes(), now.getUTCSeconds());

        var hours_ago = Math.floor(Math.abs(now_date - new Date(value.last_seen)) / 36e5);

        var readable = '';
        if (hours_ago > 24) {
            if (hours_ago > 168) {
                var weeks = Math.floor(hours_ago / 168);
                if (weeks > 4) {
                    readable = 'Inactive';
                } else if (weeks == 1) {
                    readable = weeks + ' week ago';
                } else {
                    readable = weeks + ' weeks ago';
                }
            } else {
                var days = Math.floor(hours_ago / 24);
                if (days == 1) {
                    readable = days + ' day ago';
                } else {
                    readable = days + ' days ago';
                }
            }
        } else {
            if (hours_ago == 0) {
                readable = 'Within the hour';
            } else {
                if (hours_ago == 1) {
                    readable = hours_ago + ' hour ago';
                } else {
                    readable = hours_ago + ' hours ago';
                }
            }
        }

        users[key].last_seen_hours = hours_ago;
        users[key].last_seen_readable = readable;

        users[key].created_at_readable = formatReadableDate(value.created_at);
    });

    return users;
}

function calcDaysLeft(date) {
    var now = new Date();
    var now_date = new Date(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate(),
        now.getUTCHours(), now.getUTCMinutes(), now.getUTCSeconds());

    var days = Math.floor((Math.abs(new Date(date.date) - now_date) / 36e5) / 24);

    if (days < 0) {return 'Ended'; }
    else if (days == 0) { return 'Ends today'; }
    else if (days == 1) { return days + ' day'; }
    else { return days + ' days'; }
}

function addNsfwFilter(submissions, showNsfw) {
    angular.forEach(submissions, function(value, key) {
        if (value.submission) {
            if (value.submission.nsfw && !showNsfw) {
                value.submission.secureThumb = 'resources/nsfw_thumbnail.png';
            } else {
                value.submission.secureThumb = 'api/submissions/' + value.submission.id + '/thumbnail';
            }
        } else {
            if (value.nsfw && !showNsfw) {
                value.secureThumb = 'resources/nsfw_thumbnail.png';
            } else {
                value.secureThumb = 'api/submissions/' + value.id + '/thumbnail';
            }
        }
    });
    return submissions;
}