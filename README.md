Now supports the new Webhook method of interacting with Slack.

This is a little app notifies Slack of any changes in the build status on your CruiseControl.rb install.
It also support github as a source code repository to link to a commit. Other can easily be extended if needed

## Installation

Install as a gem

    gem install cruisecontrolrb-to-slack

or add to your Gemfile

```
# Gemfile
gem "cruisecontrolrb-to-slack"
```

and run `bundle install`

or from source

```
git clone git@github.com:epinault/cruisecontrolrb-to-slack.git
cd cruisecontrolrb-to-slack
bundle install
rake build
gem install ./pkg/cruisecontrolrb-to-slack-0.2.0.gem
```

## Configuration

First you will need to create an incoming webhook from Slack integration. You will need to copy the token and the team name of that URL to setup the next part.

Make sure to define the following environment variable as they are required in either
you `.profile` or `/etc/profile.d/cruisecontrolrc-to-slack.sh` (for all users)

```
SLACK_WEBHOOK_URL=webhook_url       # the webhook url you received from Slack
CC_HOST=your_cruise_control_host    # (e.g builder.cruisecontrol.com)
```

The following are optionals

Basic auth for your CruiseControlrb install (recommended):

```				
CC_USERNAME=your_username
CC_PASSWORD=your_password
```			

```
SLACK_USERNAME=your_username     # Name to show for the message coming in  [Default: cruisecontrol]
SLACK_CHANNEL=your_channel       # the channel to receive notification  [Default: #general] (include the '#')
POLLING_INTERVAL							   # polling interval in seconds. defaults to 5 seconds.
```

## Running

As this gem uses dante, options are best describes [here](http://github.com/nesquena/dante) but here are some very simple
setup

### Run in foreground and STDOUT output (to test most likely)

```
cruisecontrolrb-to-slack
```

### Run in foreground with logs 

```
cruisecontrolrb-to-slack -l /var/log/myapp.log
```

### Run as a daemon with a pid file and logs

```
cruisecontrolrb-to-slack -d -P /var/run/myapp.pid -l /var/log/myapp.log
```

<img width="100px" src="http://1.bp.blogspot.com/-VYkLIx6dPTE/TapmnuECsJI/AAAAAAAAALY/L3c1FY4v--w/s1600/looney_tunes_thats_all_folks.jpg"  />
