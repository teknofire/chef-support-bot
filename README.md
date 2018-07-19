# README

## Requirements

* ruby 2.4.2
* postgresql database
* bundler

## Local development setup

After downloading the application install all the required gems by running

```
bundle install
rails db:create db:migrate db:seed
```

Next, you will need to do is setup a new slack app to talk with your running instance.  You can do that by going to this page: https://api.slack.com/apps?new_app=1

Go to the `Bot Users` and create a new user for the app, then you can go to the `OAuth & Permissions` and click the `Install App to Workspace` button.

After that there are a couple of authentication tokens needed from slack that need to be added to a `.env` file in the root of the repository

* `SLACK_TOKEN` - This can be found in the `Basic Information` link and copying the `Verfication Token` value
* `SLACK_API_TOKEN` - This can be found in the `OAuth & Permissions` link and copying the `Bot User OAuth Access Token`

The contents of the file should look like this:

```
SLACK_TOKEN=VERIFICATION_TOKEN_GOES_HERE
SLACK_API_TOKEN=BOT_USER_OAUTH_ACCESS_TOKEN
```

You should then be able to run the app using

```
foreman run web &
# I also run my local instance through ngrok
ngrok http 3000
```

Once the applicaiton is running you will then need to setup slack to be able to talk to it.  
Take the ngrok url generated above and go to the `Event Subscriptions` page in the slack app setup.  
Add the following to the `Request URL` - `https://NGROK_HOST_PORT/api/events`

Then you will need to subscribe the bot to the `app_mention` and `message.im` events below that.

Additionally, `Interactive Components` will need to be enabled, and on that page the `Request URL` will use the ngrok url with a different endpoint: `https://NGROK_HOST_PORT/api/interactive`



## How to run the test suite

```
rails test
```
