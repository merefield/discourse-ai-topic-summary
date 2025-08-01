# frozen_string_literal: true
# name: discourse-ai-topic-summary
# about: Uses a remote (OpenAI) AI language model to prepare and post a summary of a Topic
# version: 0.5.9
# authors: Robert Barrow
# contact_emails: merefield@gmail.com
# url: https://github.com/merefield/discourse-ai-topic-summary

gem 'event_stream_parser', '1.0.0', { require: false }
gem "ruby-openai", '8.1.0', { require: false }

register_asset 'stylesheets/common/ai_topic_summary.scss'

enabled_site_setting :ai_topic_summary_enabled

module ::AiTopicSummary

  PLUGIN_NAME = "discourse-ai-topic-summary".freeze

  def progress_debug_message(message)
    puts "AI Topic Summary: #{message}" if SiteSetting.ai_topic_summary_verbose_console_logging
    Rails.logger.info("AI Topic Summary: #{message}") if SiteSetting.ai_topic_summary_verbose_rails_logging
  end

  module_function :progress_debug_message
end

require_relative "lib/ai_topic_summary/engine"

after_initialize do
  reloadable_patch do
    TopicListItemSerializer.prepend(AiTopicSummary::TopicListItemSerializerExtension)
    TopicView.prepend(AiTopicSummary::TopicViewExtension)
  end

  Topic.register_custom_field_type('ai_summary', :json)

  add_to_class(:topic, :ai_summary) { self.custom_fields['ai_summary'] }

  add_to_serializer(:topic_view, :ai_summary, respect_plugin_enabled: true) { object.topic.ai_summary }

  add_preloaded_topic_list_custom_field("ai_summary")

  on(:post_created) do |*params|
    post, opts, user = params

    if SiteSetting.ai_topic_summary_enabled
      skip = false

      posts_count = post.topic.posts_count

      skip = true if posts_count <= SiteSetting.ai_topic_summary_enabled_min_posts

      is_private_msg = post.topic.private_message?

      skip = true if !SiteSetting.ai_topic_summary_permitted_in_private_messages && is_private_msg

      permitted_categories = SiteSetting.ai_topic_summary_permitted_categories.split('|')

      skip = true if !SiteSetting.ai_topic_summary_permitted_all_categories && !permitted_categories.include?(post.topic.category_id.to_s)

      if !skip &&
        (post.topic.ai_summary.nil? ||
        (!post.topic.ai_summary.nil? &&
         !post.topic.ai_summary["post_count"].nil? &&
          posts_count >= post.topic.ai_summary["post_count"] + SiteSetting.ai_topic_summary_enabled_post_interval_rerun &&
          posts_count <= SiteSetting.ai_topic_summary_post_limit))
        Jobs.enqueue(:ai_topic_summary_summarise_topic, topic_id: post.topic.id)
      end
    end
  end
end
