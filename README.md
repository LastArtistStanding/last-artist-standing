# The Do Art Daily (DAD) Website
The live version of this website is available at [dad.gallery](https://dad.gallery/).
For more information about DAD, [check out the help page](https://dad.gallery/help).

## Getting started
First, install Ruby 2.6.5 via [RVM](https://rvm.io/), Bundler, and PostgreSQL if you do not have them already.

To install RVM:

```console
$ gpg2 --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
$ curl -sSL https://get.rvm.io | bash -s stable
```

To install Ruby using RVM:

```console
$ rvm install 2.6.5
$ rvm --default use 2.6.5
```

You will also need to install Bundler: `gem install bundler`.

You will need to install PostgreSQL and create yourself a user capable of creating databases. Replace `$USER` with your login.

```
$ sudo apt install postgresql
$ sudo -u postgres psql
psql=# CREATE USER $USER ;
psql=# ALTER USER $USER CREATEDB ;
```

Next, go ahead and clone and then `cd` into the app repository. You will then need to install its dependencies:

```console
$ bin/bundle install
```

Next, use `rake` to set up the database:

```console
$ bin/rake db:setup dad_tasks:update_database dad_tasks:init_site_status dad_tasks:update_patch_notes
```

Now, you'll need to create an Amazon AWS account. Don't worry; the free-tier services are sufficient to run this website. Then, [create an access key for your user account](https://docs.aws.amazon.com/general/latest/gr/managing-aws-access-keys.html) and create an S3 bucket for your local copy of DAD to use.
Put your access key and S3 bucket ID in a `.env` file in the root of the repository (the `.gitignore` file will prevent you from accidentally uploading your access keys):

```properties
AWS_ACCESS_KEY=<your access key>
AWS_SECRET_ACCESS_KEY=<your secret access key>
AWS_S3_BUCKET=<your bucket id>
AWS_REGION=<the region your bucket is in, or us-east-2 if unspecified>
```

If you are on a Unix-based system with `sendmail` installed,
and are able to access your user email folder on `/var/mail`,
you can also add this setting to redirect all emails that get sent to you.
Otherwise, emails will fail to be sent (although they will still be visible in the server log).
This only applies to the development environment.

```properties
REDIRECT_MAIL=unix
```

You will need to add this permission policy to your bucket:

```JSON
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::<your AWS account id>:root"
            },
            "Action": "s3:*",
            "Resource": [
                "arn:aws:s3:::<your bucket id>",
                "arn:aws:s3:::<your bucket id>/*"
            ]
        }
    ]
}
```

The website has a test suite, which you can run to make sure things are set up properly.
If you make a change to the site, you should make sure that all of the tests still pass.
Here's how you run the tests:

```console
$ bin/rake test
$ bin/rspec spec/
```

It does *not* test your S3 configuration; you can verify that S3 works by manually uploading a submission.

Now, you'll be ready to run the app in a local server:

```console
$ bin/rails server
```

To cause the site to process user streaks, eliminations, and challenges, you will need to run `bin/rake dad_tasks:rollover_script`.
On the production website, that task runs at 12:00 AM UTC every night.

For more information, see the
[*Ruby on Rails Tutorial* book](http://www.railstutorial.org/book).
