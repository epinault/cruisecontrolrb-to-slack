require 'test_helper'

describe CruisecontrolrbToSlack::SlackClient do
  subject{CruisecontrolrbToSlack::SlackClient.new('team', 'token')}

  it 'should use the default  a new instance' do
    subject.client.must_be_kind_of Slack::Notifier
  end 

  it 'should set the team properly' do
    subject.client.team.must_equal 'team'
  end

  it 'should set the token properly' do
    subject.client.token.must_equal 'token'
  end

  it 'should set the default channel to #general' do
    subject.client.channel.must_equal '#general'
  end

  it 'should set the default user to cruisecontrol' do
    subject.client.default_payload[:username].must_equal 'cruisecontrol'
  end

  it 'should override the default channel ' do
    slack_client = CruisecontrolrbToSlack::SlackClient.new('team', 'token', channel: 'channel')
    slack_client.client.channel.must_equal 'channel'
  end

  it 'should override the default user ' do
    slack_client = CruisecontrolrbToSlack::SlackClient.new('team', 'token', user: 'user')
    slack_client.client.default_payload[:username].must_equal 'user'
  end
end