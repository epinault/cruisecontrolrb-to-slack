require 'test_helper'

describe CruisecontrolrbToSlack::Runner do
  subject{CruisecontrolrbToSlack::Runner.new({})}
  let(:slack_client){Minitest::Mock.new}
  let(:cc_client){Minitest::Mock.new}
  
  it 'check the status and have no status fetch' do 
    cc_client.expect :fetch_statuses, {}
    subject.stub :cc_client, cc_client do
      subject.check_statuses.must_be_nil
      cc_client.verify
    end
  end

  it 'check the status and have a building status' do 
    slack_client.expect :send_message, true, 
                        ['CruiseControl has started to build project project1. <http://host:3333/builds/project1/5d1d1ed4529dfdc864129691e480990e5751981f.17|See details>', 
                          {icon_emoji: ':mega:'}]
    subject.cc_client.stub :retrieve_content, load_data_file('building.xml') do
      subject.stub :slack_client, slack_client do

        subject.check_statuses
        slack_client.verify
      end
    end
  end

  it 'should build the url for the status' do
    subject.build_url_for_status(web_url: 'host/projects/project1', 
                                build_label: 'mylabel').must_equal 'host/builds/project1/mylabel'
  end


end