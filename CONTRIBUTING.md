# Contributing
If you are interested in making code or similar contributions to the site,
please contact the1banana or Puma and we can help get you started individually.

## Making bug reports
If you discover a bug, you may open an issue on GitHub,
or notify the developers through one of the many existing channels
(such as `#site-discussion` on the Official DAD Discord).
Bugs reported in the LAS thread will not necessarily be seen and are prone to starting drama,
so please prefer reporting bugs in a different way when possible.

If you discover a *security* bug, please contact the1banana directly
so that it will not be known to the public until it is fixed.

## Making suggestions
Similarly to with bug reports, `#site-discussion` or DMing a dev team member is the way to go.

## Writing code
### What should I work on?
Ask one of the existing developers; we can discuss something for you to work on.

Currently, most discussion and planning goes on in Discord DMs rather than GitHub,
so just trying to pick an issue to fix or feature to implement probably isn't a good idea.

### Navigating the codebase
The site is written using Ruby on Rails,
so you may want to [read the RoR tutorial book](https://www.railstutorial.org/book),
or reference [the Rails Guides](https://guides.rubyonrails.org/index.html).

Understanding how things work can be difficult if you have not used Rails before,
so feel free to ask Puma if you need help.

### Making a pull request
Before you commit, make sure the test suite still passes:

```console
$ bin/rake test
$ bin/rspec spec/
```

Make sure your code passes the linter, `rubocop --fail-level W`.
Your code does not necessarily need to pass every lint
(the configuration isn't fined-tuned enough for that to be viable yet),
but you should make an effort to minimize issues where possible.

Make sure you've written unit tests for your new features or bugfixes.
RSpec tests are preferred when possible, though either option is acceptable.

Make sure your pull request is up to date with the `master` branch.
Rebase your changes onto `master` (`git rebase master`) if it becomes out of sync.
If you don't know how to do that, I can take care of it for now,
but you really ought to learn when you have the chance.

You're encouraged to maintain a good Git history:
commits should represent individually meaningful changes.
Avoid making multiple unrelated changes in one commit,
or making multiple commits which depend on one another
(e.g. if you apply one without another, the app will not function).
You can accomplish this with rebases and amendments.
If you don't know how to do this (or even what I mean), that's *okay*,
but your PR will likely be squashed and merged as a single commit.

Finally, make sure you're making the codebase better than you started with.
The codebase leaves a lot to be desired, so we strive to improve it incrementally with every change.

Your pull request will be reviewed, so be prepared for changes to be requested before it is merged.

Thanks for considering contributing!
