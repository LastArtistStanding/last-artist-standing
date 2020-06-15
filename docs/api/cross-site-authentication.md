# The cross-site authentication API
The cross-site authentication API allows you to create additional websites
that use your DAD account for long-in.

This API allows users to prove their identity to other pre-configured sites
without having to give that site their login information or session token.

Users can even be logged in to these external sites completely automatically.

## How to configure it
When you set these environment variables:

```properties
# The domain name of the site you want to allow DAD log-ins on
X_AUTH_HOST=example.com
# A secret code shared with that site.
X_AUTH_SECRET=<some random secret data>
```

The cross-site authentication API will be enabled.

## How to use it
### High-level overview
Suppose you want to use your DAD account to log in to Zone (some other website using this API).
You don't want to give Zone your login information or session cookie,
because then they could log in as you.

DAD has the ability to make claims that Zone can verify using a shared secret.
You already have a way to prove to DAD who you are (logging in),
so what you need is some way to get DAD to vouch for who you are for Zone.

In this case, the way you can get DAD to make a claim about who you are
is through the `/x_site_auth/sign` endpoint.
If you `POST` to it, DAD will return some data which contains your user id,
and signed by DAD so that Zone can *verify* that it's associated with you.
You can then `POST` that data to Zone's login endpoint (implementing that is your job),
and Zone, now satisfied that you are who you claim to be, will log you in.

The data returned by DAD also includes an expiration time
so that if someone gets access to your account,
they won't be able to get permanent access to your Zone data.
(They'll still be able to log in, but only for as long as they have access to your DAD account.)

Additionally, it includes a single-use code which may be selected by Zone.
ensuring that if DAD accidentally issues a verification token that lasts too long,
Zone will also be able to enforce an expiration time on its end
and prevent it from being used more than once.
It also ensures that, if multiple x-auth sites were set up,
that one x-auth site could not use a user's signed login information
to log in to that user's account on *other* x-auth sites.
The single-use code must be provided to the `sign` endpoint as the `code post parameter.`

### The login flow
The API is intended to be invoked from the user's web browser a web browser using the
[Fetch API](https://developer.mozilla.org/en-US/docs/Web/API/Fetch_API).

When a user visits your site for the first time, you should `GET /x_site_auth/auto_login_available`.
It will return either `true` or `false`, as plain text.

If it returns `true`, then the user is logged in on DAD, and you can log them in:

1. Ask Zone to generate a single-use code to sign.
2. `POST` `{ "code": "<the code>" }` to `/x_site_auth/sign`
   * If the API returns `unauthorized`, then proceed as if the user were not logged in.
   * Otherwise, the API will return a plain-text [JSON Web Token](https://jwt.io/) with this data,
     signed using HMAC256 and the shared secret specified by `X_AUTH_SECRET`.
     * `"code": "<the same code passed in>"`
     * `"user_id": <the id of the DAD user currently logged in>`
     * `"exp": "<date>"` where `date` is an ISO_8601 date representing the expiry of the token.
3. `POST` the JWT to the Zone login API, which will verify the authenticity of the data and log you in.

If it returned `false` (or something went wrong in the steps above),
please store that the login failed in a cookie to avoid spamming the DAD API with login requests
each time the user visits any page on your site, and proceed as follows:

1. Offer the user a login button resetting your "login failed" cookie
   and redirecting the user to `/x_site_auth/login?return_to={:url}`
   where `:url` is the page you want the user to land on after they've logged in
   (most likely, this will be whatever page they are on *before* logging in).
   The URL must be an absolute URL using the `https:` scheme
   and the host specified by the `X_AUTH_HOST` environment variable.
2. At some point, the user presses the login button and will visit the x-site auth login page.
   * If the user is not logged in, they will be prompted to log in.
   * The user's `x_auth` cookie will be set, which will cause `auto_login_available` to return true.
   * The user will be redirected back to the specified URL.
3. Your code will repeat this process, only this time, `auto_login_available` will return true,
   and the user will be successfully logged in!

## How it works
This is an extension of the information available in "how to use it"
that goes into more detail and discusses the security implications.

### Why it's secure
When you're log in to DAD, you have a `session` cookie set, which proves who you are to DAD
(until it expires or you log out, in which case you'll have to log back in again).
Being logged in with the `session` cookie is what allows you to do stuff on the site,
such as creating submissions, editing your account, joining challenges, etc.
The session cookie would normally be sent with every request you make to DAD.

To get DAD to sign our code so we can log in to Zone, we have to prove who we are,
which would be as simple as logging in on DAD, setting our session cookie,
and Zone's JavaScript code asking our browser to submit to the `sign` endpoint.

Only... it's not that simple.
What if Zone, instead of telling our browser to request DAD to `sign`,
it told the browser to ask DAD to delete all of our comments?
To avoid this issue, cookies have an attribute, `SameSite`,
which tells the browser that the cookie should only be sent when you're on DAD,
and not when you're on any other site.
We definitely don't want to open up that security hole, so instead we make our own cookie, `x_auth`.
It behaves exactly like a session cookie, except it's only valid for `/x_site_auth` APIs,
and it can be used from any domain.
`x_auth` will normally be set whenever the user logs in,
and will be re-set if the user visits `/x_site_auth/login`.

There's more to it than that though. What if a site other than Zone asked us to `sign` something,
and then used it to log into your Zone account?
To prevent this, we have [Cross-Origin Resource Sharing (CORS)](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS).
It means that a browser can't send non-trivial requests
(e.g. POST requests or requests requiring authentication cookies like `x_auth`)
unless the server specifically tells them that they're allowed to.
In this case, we allow all `/x_site_auth` endpoints to use POST requests with authentication cookies,
but only when those requests originate from `X_AUTH_HOST`, to prevent the described exploit.

### Reference
The API introduces these endpoints:

* `GET /x_site_auth/auto_login_available`:
  * On success, this endpoint renders plain text:
    * `true` if the sender has the `x_auth` cookie set
    * `false` otherwise
  * This endpoint cannot fail.
* `GET /x_site_auth/login?return_to={:url}`
  * `:url` must be an absolute URL using the `https:` scheme and `$X_AUTH_HOST` host.
    * The API will render the `unauthorized` page if `:url` is incorrect.
  * If the sender is not logged in, they will be prompted to log in.
  * If the sender *is* logged in, their `x_auth` cookie will be set and they will be redirected to {:url}.
* `POST /x_site_auth/sign`, `{ "code": "<some random secret data>" }`
  * `:code` must be present; the value is irrelevant and may be chosen by the sender.
  * If the user's `x_auth` cookie is not set or is correct, `unauthorized` will be returned.
  * Otherwise, the API will return a JWT with this data:
    `{ code: "<the same data passed in>", user: "<the logged-in user's id>", exp: "<ISO 8601 date>" }`

The `x_auth` cookie contains this data: `<user id>/<x-auth session token>`.
Normally the identity of the logged-in user could by discovered through the session token,
but in this case we don't have that, so we have to track which user the session token is for ourselves.
