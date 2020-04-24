# The Do Art Daily (DAD) Website
The live version of this website is available at [dad.gallery](https://dad.gallery/).
For more information about DAD, [check out the help page](https://dad.gallery/help).

## Getting started
First, install Ruby 2.6.5 via [RVM](https://rvm.io/), Bundler, and PostgreSQL if you do not have them already.

To install RVM:
```bash
gpg2 --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
curl -sSL https://get.rvm.io | bash -s stable
```

To install Ruby using RVM:
```bash
rvm install 2.6.5
rvm --default use 2.6.5
```

You will also need to install Bundler.
I believe this should be as simple as `gem install bundler`, but I have not tested this.

You can install PostgreSQL with APT: `apt install postgresql`.
You will then need to create yourself a database user, create a database for DAD, and grant yourself access to the new database:
```
$ sudo -u postgres createuser $USER
$ sudo -u postgres createdb database_development
$ sudo -u postgres psql
psql=# grant all privileges on database database_development to <username> ;
```

Next, go ahead and clone and then `cd` into the app repository. You will then need to install its dependencies:
```
$ bundle install
```

Next, perform the database migrations:

```
$ rails db:migrate
```

You will need to run a few tasks to initialize the database:

```
$ rake dad_tasks:update_database
$ rake dad_tasks:init_site_status
```

Now, you'll need to create an Amazon AWS account. Don't worry; the free-tier services are sufficient to run this website. Then, [create an access key for your user account](https://docs.aws.amazon.com/general/latest/gr/managing-aws-access-keys.html) and create an S3 bucket for your local copy of DAD to use.
Put your access key and S3 bucket ID in a `.env` file in the root of the repository (the `.gitignore` file will prevent you from accidentally uploading your access keys):
```
AWS_ACCESS_KEY=<your access key>
AWS_SECRET_ACCESS_KEY=<your secret access key>
AWS_S3_BUCKET=<your bucket id>
AWS_REGION=<the region your bucket is in, or us-east-2 if unspecified>
```

You will need to add this permission policy to your bucket:
```
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

You may have noticed that the website has a test suite.
Do not bother trying to run it; it is unmaintained and *will* fail.

Now, you'll be ready to run the app in a local server:

```
$ rails server
```

For more information, see the
[*Ruby on Rails Tutorial* book](http://www.railstutorial.org/book).
