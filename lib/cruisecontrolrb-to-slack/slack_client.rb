module CruisecontrolrbToSlack
  class SlackClient
    attr_reader :client

    def initialize(webhook, options = {})
      user = options[:user] || 'cruisecontrol'   
      channel = options[:channel] || '#general'

      @client = Slack::Notifier.new webhook, channel: channel, username: user
    end

    # 
    # options: See https://github.com/stevenosloan/slack-notifier , additional parameters
    #
    def send_message(mesg, options = {})
      @client.ping mesg, options
    end

  end
end
