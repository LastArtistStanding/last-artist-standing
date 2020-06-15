# The Do Art Daily (DAD) Website
The live version of this website is available at [dad.gallery](https://dad.gallery/).
For more information about DAD, [check out the help page](https://dad.gallery/help).

## Getting started
These instructions describe how to get a copy of the site working
on your local machine for development and testing purposes.
The instructions may seem long, but many steps are optional.

It is recommended that you develop this site on Linux.
If you cannot run Linux, Windows Subsystem for Linux (WSL) 2 will be sufficient.
Do *not* try to use Cygwin; it will not work.

### Prerequisites
You will need to install this software to build and run the site:

* Ruby 2.6.5
* Bundler
* PostgreSQL
* ImageMagick
* `libpq-dev`

You will need to install Ruby 2.6.5. The easiest way to do this with [RVM](https://rvm.io/), the Ruby Version Manager.

First, install RVM:

```console
$ gpg2 --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
$ curl -sSL https://get.rvm.io | bash -s stable
```

Next, install Ruby 2.6.5 using RVM and set it to be used
in preference to any version which may already be installed on your system:

```console
$ rvm install 2.6.5
$ rvm --default use 2.6.5
```

Next, install Bundler: `gem install bundler`.

Finally, you will need to set up PostgreSQL.
On Debian derivatives, simply `apt install postgresql`.

### Installing and Configuring
Throughout this process, you may need to set environment variables.
You may set them in the usual way or put them in a `.env` file in the application root
(I would recommend the latter).
The `.gitignore` file will prevent you from accidentally committing any access keys put in this file.

Use Git to clone and `cd` into the app repository.

Next, install its dependencies:

```console
$ bundle install
```

#### Setting up the database
You will need to give your user account the ability to create databases. Replace `$USER` with your login.

```
$ sudo -u postgres psql
psql=# CREATE USER $USER ;
psql=# ALTER USER $USER CREATEDB ;
```

Alternatively, you may manually create new databases and/or users,
and pass the database access information as a `postgres:` URL in the `DATABASE_URL` environment variable.
The default database names are `database_development` and `database_testing`
for the development and testing environments respectively.

Next, use `rake` to set up the database:

```console
$ rake db:setup dad_tasks:update_database dad_tasks:init_site_status dad_tasks:update_patch_notes
```

`db:setup` will create the necessary databases and perform migrations.
The other tasks are app-specific administrative tasks whose specific function isn't relevant right now.

#### Setting up a file upload backend
You may use either local file uploads or Amazon S3.
If you would prefer to use the file-based backend, you can skip the following step.

If you'd prefer to use S3, you'll need an Amazon S3 account.
Fortunately, the free-tier services are sufficient to run the development version of this website,
so you will not need to spend any money (although signup will require giving payment information).

Next, [create an access key for your user account](https://docs.aws.amazon.com/general/latest/gr/managing-aws-access-keys.html) and create an S3 bucket for your local copy of DAD to use.
Set your AWS access keys and S3 bucket ID in environment variables or in your `.env` file:

```properties
AWS_ACCESS_KEY=<your access key>
AWS_SECRET_ACCESS_KEY=<your secret access key>
AWS_S3_BUCKET=<your bucket id>
AWS_REGION=<the region your bucket is in, or us-east-2 by default>
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

Fine-grained security access is not necessary because only this app will need to access your bucket.

#### Configuring mail delivery
The website may need to deliver email for functionality like email address verification and password resets.
In production, the app sends emails using sendgrid, but locally, you won't have access to that.
If you do not set up a mail delivery service, mail delivery will fail silently,
which may be acceptable in the development environment,
since you can read the mails the application attempts to send from the log or stdout.

However, if you are on a Unix-based system with `sendmail`,
and you are able to access your email folder on `/var/mail`, you have another option:
have all emails sent by the application be redirected to your local mail.
Simply set this environment variable:

```properties
REDIRECT_MAIL=unix
```

The `REDIRECT_MAIL` environment variable only affects the development environment; not production or testing.

#### Additional options
To set your DAD account as an administrator: `UPDATE users SET is_admin = TRUE ;`.

```properties
# Closes user registrations except for when manually created by an administrator.
DISABLE_REGISTRATION=TRUE

# Opens moderator applications until the given date.
# You may view them using an administrator account at `/moderator_applications`.
MODERATOR_APPLICATIONS=YYYY-MM-DD

# Allows serving HTTPS in the development environment.
# You must put your key in `private/key.pem` and your cert in `private/cert.pem`.
# HTTPS will be served on port 3001.
# This must be the domain you're going to serve HTTPS on.
# Using this will require un-commenting some code in `config/puma.rb`,
# which, if uncommented, breaks production for reasons I cannot explain.
DEVELOPMENT_TLS=example.com

# Allows cross-site authentication (i.e. using your DAD account to log in to) this hostname.
# This will usually require DEVELOPMENT_TLS to function properly/
# A hostname is either a domain name or an IP address.
X_AUTH_HOST=example.com
# This secret must also be configured for the other site for which x-auth is enabled.
X_AUTH_SECRET=shared HMAC secret
```

#### See if it works!
You may choose to run the test suite to make sure everything was set up properly:

```console
$ bin/rake test
$ bin/rspec
```

The test suite should report no errors.

Note that the test suite will *not* test your S3 or mail configuration;
you'll have to find out whether those work manually
(e.g. by attempting to upload a submission or registering a user)

Now, you'll be ready to run the app in a local server:

```console
$ bin/rails server
```

To cause the site to process user streaks, eliminations, and challenges, you will need to run `bin/rake dad_tasks:rollover_script`.
On the production website, that task runs at 12:00 AM UTC every night.

Locally, your site will (by default) be hosted at http://localhost:3000/.

## Contributing
Please read [CONTRIBUTING.md](https://github.com/LastArtistStanding/last-artist-standing/blob/master/docs/CONTRIBUTING.md)
if you would like to help contribute to the project.
