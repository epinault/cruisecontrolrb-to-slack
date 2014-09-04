require 'httparty'
require 'nokogiri'
require 'slack-notifier'
require 'dante'
require 'rufus-scheduler'
require "cruisecontrolrb-to-slack/version"
require "cruisecontrolrb-to-slack/cruisecontrolrb"
require "cruisecontrolrb-to-slack/slack_client"

module CruisecontrolrbToSlack

  class Runner
    attr_accessor :previous_statuses , :current_activities
    attr_reader :config, :slack_client, :cc_client
    FAILED_EMOJIS = [':speak_no_evil:', ':see_no_evil:', ':hear_no_evil:']

    def self.run(config)
      new(config).execute
    end

    def initialize(config)
      @config = config
      @previous_statuses = {}
      @current_activities = {}
      @slack_client = SlackClient.new(config[:slack_team], config[:slack_hook_token], 
                                channel: config[:slack_channel], user: config[:slack_user])
      @cc_client = Cruisecontrolrb.new(config[:cc_host], config[:cc_username], config[:cc_password])
    end

    def execute
      scheduler = Rufus::Scheduler.new(:blocking => true, :overlap => false)
      
      scheduler.every("#{config[:polling_interval]}s") do  

        statuses = cc_client.fetch_statuses

        unless statuses.empty?     

          statuses.each do |status_hash|   
            name = status_hash[:name]
            url = File.join(status_hash[:web_url].gsub("projects", "builds"), status_hash[:build_label])

            if status_hash[:activity] == "Building" and current_activities[name] != "Building"
              msg = "CruiseControl has started to build project #{name}. <#{url}|See details>"
              slack_client.send_message msg, icon_emoji: ':mega:'
              current_activities[name] = "Building"
            elsif (current_activities[name] == "Building" and status_hash[:activity] != "Building")
              current_activities[name] = status_hash[:activity]
              project_details = cc_client.fetch_project_details(name)

              color = (status_hash[:status] == "Success") ? "good" : "danger"
              emoji = (status_hash[:status] == "Success") ? ":tada:" : FAILED_EMOJIS[rand(3)]

              message = (status_hash[:status] == "Success") ? "<#{url}|Success!> #{name} is looking good. You are a stud! :D" : "You are a failure! #{name} is broken. <a href=\"#{url}\">See details</a> and fix it now! >:-(" 
              attachment = {
                            fallback: project_details[:commit_comment],
                            color: color,
                            mrkdwn_in: ["text", "title", "fields", "fallback"],
                            fields: [{title: 'Commit Msg:', value: project_details[:commit_comment]},
                                      {title: 'Commit', value: "<#{project_details[:commit_url]}|#{project_details[:commit]}>", short: 'true'}, 
                                      {title: 'Committer', value: project_details[:committer], short: 'true'}]
                        }
              slack_client.send_message message, icon_emoji: emoji, color: color, attachments: [attachment]
            end
          end
        end
      end

      scheduler.join
    end

  end
end
