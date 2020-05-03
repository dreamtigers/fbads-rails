# fbads-rails

Ruby on Rails reimplementation of
[fbadsPortalCopy](https://github.com/tblumer3/fbadsPortalCopy).

The app uses Facebook's API:
- Facebook Graph and Marketing API to get and post information, e.g.:
    - Get a list of the pages that belong to an account.
    - Get a list of the ads that belong to and ad account.
    - Post a new ad campaign.
    - Post a new ad.
- Facebook Pixel to track the website visitors' actions.


# Dependencies

- Ruby version: ruby 2.6.5
- System dependencies:
    - PostgreSQL 12.

# Configuration

## Facebook

### Graph and Marketing API

To set up the Graph and Marketing API:

- Login as a facebook developer.
- Create a new app.
- Set up the Facebook Login.
    - Add the site URL (in my case it was https://fbads-rails.herokuapp.com)
    - Add Valid OAuth redirect URIs:
        - In your app dashboard, go **Facebook Login**
        - **Settings**
        - In the field **Valid OAuth Redirect URIs**, add the redirect URI of
          your app.
        - In my case it was
          https://fbads-rails.herokuapp.com/auth/facebook/callback, in yours
          will probably be <URL_TO_YOUR_APP>/auth/facebook/callback.
- Set up the Marketing API.

### Facebook Pixed ID

To set up Facebook Pixel ID:

- Follow these instructions:
  https://www.facebook.com/business/help/952192354843755?id=1205376682832142
- Once you have your Pixel ID, add it to your environment.


## Production environment

The preferred way to do set up the variables used by the app is with the
command `rails credentials:edit`, which needs the `master.key` file to decrypt
it:

```sh
$ rails credentials:edit
```

Should show you:

```yml
fb_app:
    id: <NUM_STRING>
    secret: <STRING>

secret_key_base: <STRING>
```

If you prefer to use environment variable, you'll have to set up these:
- Used by omniauth to authenticate (OAuth) the app with Facebook:
    - `FACEBOOK_APP_ID`: The ID of your Facebook App.
    - `FACEBOOK_APP_SECRET`: The secret key of your Facebook App.
- Used by facebook-ruby-business-sdk to use Facebook's API:
    - `FB_APP_SECRET`: Same as `FACEBOOK_APP_SECRET`.
- Used by Rails itself:
    - `RAILS_ENV`: Determine if Rails will run in development, testing, or
      production mode.
    - `RAILS_MASTER_KEY`: Used to decrypt `credentials.yml.enc` if your
      deployment doesn't have a `master.key` file.

You can set these variables in Heroku, goin to the Heroku app dashboard, click
on **Settings**, and then **Reveal Config Vars**.

# Deployment to Heroku

Login to Heroku:
```sh
$ heroku login
```
Change to the project directory, add heroku as a remote:

```sh
$ cd fbads-rails
$ heroku git:remote -a fbads-rails
```

With this, the project should be installed (but still unaccessible) as
a Heroku app. It's unaccessible because the database is empty, you have to
tell it through Heroku to load the schema:

```sh
$ heroku run rake db:schema:load
```

With that, you're done!
