require 'test_helper'

describe CruisecontrolrbToSlack::Cruisecontrolrb do
  subject{CruisecontrolrbToSlack::Cruisecontrolrb.new('host')}

  it 'fetch the status and parse it' do
    xml = load_data_file('all_projects_statuses.xml')

    subject.stub :retrieve_content, xml do
      resp = subject.fetch_statuses
      resp.length.must_equal 3
      resp[0][:web_url].must_equal 'http://host:3333/projects/project1'
      resp[0][:status].must_equal 'Failure'
      resp[0][:build_label].must_equal '5d1d1ed4529dfdc864129691e480990e5751981f.17'
      resp[0][:activity].must_equal 'CheckingModifications'
      resp[0][:name].must_equal 'project1'
    end
  end

  it 'fetch the project details and parse it correctly' do
    xml = load_data_file('project_details.xml')

    subject.stub :retrieve_content, xml do
      resp = subject.fetch_project_details('test')
      resp[:committer].must_equal 'epinault'
      resp[:commit_time].must_equal '2014-03-19 17:56:36'
      resp[:commit].must_equal '5d1d1ed4529'
      resp[:description].must_match /<pre>Build was manually requested.+<\/pre>/m
      resp[:title].must_equal 'project1 build 5d1d1ed.18 failed'
      resp[:commit_comment].must_equal 'Some cool commit message'
      resp[:commit_url].must_equal 'https://github.com/zumobi/test/commit/5d1d1ed4529'
    end

  end

end