# name: discourse-ai-topic-summary
# about: Uses a remote AI language model to prepare and post a summary of a Topic
# version: 0.0.1
# authors: Robert Barrow
# contact_emails: merefield@gmail.com
# url: https://github.com/merefield/discourse-ai-topic-summary

gem "httparty", '0.21.0' #, {require: false}
gem "ruby-openai", '3.3.0', {require: false}

enabled_site_setting :ai_topic_summary_enabled

%w[
  ../lib/engine.rb
  ../lib/call_bot.rb
  ../lib/summarise.rb
].each do |path|
  load File.expand_path(path, __FILE__)
end

after_initialize do
  Topic.register_custom_field_type('ai_summary', :json)

  add_to_class(:topic, :ai_summary) { self.custom_fields['ai_summary'] }

  add_to_class(:topic, "ai_summary=") do |value|
    custom_fields[ai_summary] = value
  end

  add_to_serializer(:topic_view, :ai_summary, false) { object.topic.ai_summary }

  add_preloaded_topic_list_custom_field("ai_summary")

  DiscourseEvent.on(:post_created) do |*params|
    post, opts, user = params

    if SiteSetting.ai_topic_summary_enabled
      permitted_categories = SiteSetting.ai_topic_summary_permitted_categories.split('|')
      is_private_msg = post.topic.private_message?

      if SiteSetting.ai_topic_summary_permitted_in_private_messages || !is_private_msg && SiteSetting.ai_topic_summary_permitted_all_categories || (permitted_categories.include? post.topic.category_id.to_s)
         if post.topic.posts_count > SiteSetting.ai_topic_summary_enabled_min_posts
            if post.topic.ai_summary.nil? || (!post.topic.ai_summary.nil? && !post.topic.ai_summary["post_count"].nil? && post.topic.posts_count >= post.topic.ai_summary["post_count"] + SiteSetting.ai_topic_summary_enabled_post_interval_rerun)
              summary_text = ::AITopicSummary::Summarise.return_summary(post.topic.id)
              current_topic = Topic.find(post.topic.id)
              current_topic.custom_fields["ai_summary"] = {"text": summary_text, "post_count": post.topic.posts_count}
              current_topic.save!
            end
         end
      end
    end
  end
end
