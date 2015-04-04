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
    attr_reader :config
    FAILED_EMOJIS = [':speak_no_evil:', ':see_no_evil:', ':hear_no_evil:']

    def self.run(config)
      new(config).execute
    end

    def initialize(config)
      @config = config
      @previous_statuses = {}
      @current_activities = {}
     end

    def execute
      scheduler = Rufus::Scheduler.new(:blocking => true, :overlap => false)
      
      scheduler.every("#{config[:polling_interval]}s") do  
        check_statuses
      end

      scheduler.join
    end

    def check_statuses
      statuses = cc_client.fetch_statuses
      unless statuses.empty?     

        statuses.each do |status_hash|   
          name = status_hash[:name]

          if status_hash[:activity] == "Building" and current_activities[name] != "Building"
            message, options = build_start_message(status_hash)
            submit_message(message, options)
            current_activities[name] = "Building"
          elsif (current_activities[name] == "Building" and status_hash[:activity] != "Building")
            current_activities[name] = status_hash[:activity]
            message, options = build_end_message(status_hash)
            submit_message(message, options)
          end

        end
      end
    end

    def build_start_message(status_hash)
      msg = "CruiseControl has started to build project #{status_hash[:name]}. <#{build_url_for_status(status_hash)}|See details>"

      [msg,{icon_emoji: ':mega:'}]
    end

    def build_end_message(status_hash)
      name = status_hash[:name]
      url = build_url_for_status(status_hash)

      project_details = fetch_details(name)

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

      options = {icon_emoji: emoji, color: color, attachments: [attachment]}
      [message, options]
    end

    def build_url_for_status(status_hash)
      File.join(status_hash[:web_url].gsub("projects", "builds"), status_hash[:build_label])
    end

    def submit_message(message, options)
      slack_client.send_message message, options
    end

    def fetch_details(name)
      cc_client.fetch_project_details(name)
    end

    def slack_client
      @slack_client ||= SlackClient.new(config[:slack_webhook_url],
                                channel: config[:slack_channel], user: config[:slack_user])
    end

    def cc_client
      @cc_client ||= Cruisecontrolrb.new(config[:cc_host], config[:cc_username], config[:cc_password])
    end

  end
end
