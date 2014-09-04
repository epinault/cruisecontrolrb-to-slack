module CruisecontrolrbToSlack

  class Cruisecontrolrb
    
    include HTTParty
    
    def initialize(base_url, username = nil, password = nil)
      @auth = { :username => username, :password => password }
      @base_url = base_url
    end
    
    def fetch_statuses
      noko = Nokogiri::XML(retrieve_content("http://#{@base_url}/XmlStatusReport.aspx"))
      projects = noko.search("Project")
      return [] unless projects.first
      
      projects.map do |project|

        status_hash = { 
                        status: project["lastBuildStatus"],
                        web_url: project["webUrl"],
                        build_label: project["lastBuildLabel"],
                        activity: project["activity"],
                        name: project['name'] }
        status_hash
      end        
    end

    def fetch_project_details(project)
      noko = Nokogiri::XML(retrieve_content("http://#{@base_url}/projects/#{project}.rss"))
       item_node = noko.search("item")
       return {} unless item_node.first

       item = item_node.first

       commit = item.at('guid').text.split('/')[-1]
       description = item.at('description').text
       title = item.at('title').text

       commit_details = description.match(/committed by (.+)/)[1].split(' ' )
       committer = commit_details[0]
       commit_time = commit_details[-2..-1].join(' ')
       commit_comment = description.split("\n\n")[1]

       {
        commit_url: "https://github.com/zumobi/#{project}/commit/#{commit[0..10]}",
        committer: committer,
        commit_time: commit_time,
        commit: commit[0..10],
        commit_comment: commit_comment.strip,
        description: description,
        title: title,
       }
    end

    private 

    def retrieve_content(url)
      options = { :basic_auth => @auth }
      self.class.get(url, options).parsed_response
    end

  end  

end