# frozen_string_literal: true
class ::AiTopicSummary::Summarise
  
  def self.retrieve_summary(topic_id)
    data = self.get_markdown(topic_id)
    summary = ::AiTopicSummary::CallBot.get_response(data).strip

    current_topic = Topic.find(topic_id)
    current_topic.custom_fields["ai_summary"] = {"text": summary, "post_count":current_topic.posts_count, "downvoted": []}
    current_topic.save!

    if SiteSetting.ai_topic_summary_enable_auto_tagging
      tags_string = "['" + Tag.pluck(:name).join("', '") + "']"
      query = I18n.t("ai_topic_summary.prompt.tag", tags: tags_string, summary: summary)

      tags_response = ::AiTopicSummary::CallBot.get_response(query).strip.chomp('.')

      tag_name_list = tags_response.split(",")
      if SiteSetting.force_lowercase_tags
        tag_name_list = tag_name_list.map { |string| string.downcase }
      end
      tag_name_list = tag_name_list.map { |string| string.strip.gsub(/[ .]/, "-") }

      if SiteSetting.ai_topic_summary_auto_tagging_username.blank?
        DiscourseTagging.tag_topic_by_names(current_topic, Guardian.new(Discourse.system_user), tag_name_list)
      else
        tagging_user = User.find_by(username: SiteSetting.ai_topic_summary_auto_tagging_username)
        if tagging_user
          DiscourseTagging.tag_topic_by_names(current_topic, Guardian.new(tagging_user), tag_name_list)
        end
      end
    end
  end

  def self.get_markdown(topic_id)
    system_user = User.find(-1)
    topic_view = TopicView.new(topic_id, system_user)
    content = []

    if ["gpt-3.5-turbo", "gpt-4"].include?(SiteSetting.ai_topic_summary_open_ai_model) ||
      SiteSetting.ai_topic_summary_open_ai_model_custom && SiteSetting.ai_topic_summary_open_ai_model_type == "chat"
      messages = [{ "role": "system", "content": I18n.t("ai_topic_summary.prompt.system") }]
      messages << { "role": "user", "content":  I18n.t("ai_topic_summary.prompt.title", username: User.find(topic_view.topic.user_id).username, topic_title: topic_view.title) }
    end

    topic_view.posts.each_with_index do |p, index|
      next if p.post_type > 1
      break if index > SiteSetting.ai_topic_summary_post_limit
      raw_post_contents = p.raw
      raw_post_contents.gsub!(/\[quote.*?\](.*?)\[\/quote\]/m,'') if SiteSetting.ai_topic_summary_strip_quotes

      if SiteSetting.ai_topic_summary_open_ai_model == "gpt-3.5-turbo" ||
        SiteSetting.ai_topic_summary_open_ai_model_custom && SiteSetting.ai_topic_summary_open_ai_model_type == "chat"
        messages << { "role": "user", "content": I18n.t("ai_topic_summary.prompt.post", username: p.user.username, raw: raw_post_contents) }
      else
        content << I18n.t("ai_topic_summary.prompt.post", username: p.user.username, raw: raw_post_contents)
      end
    end

    unless ["gpt-3.5-turbo", "gpt-4"].include?(SiteSetting.ai_topic_summary_open_ai_model) ||
      SiteSetting.ai_topic_summary_open_ai_model_custom && SiteSetting.ai_topic_summary_open_ai_model_type == "chat"
      result = content.join
      result = result[0..SiteSetting.ai_topic_summary_character_limit]
      result[0...result.rindex('.')] << "."
    else
      messages << { "role": "user", "content":  I18n.t("ai_topic_summary.prompt.summarise_chat")}
    end
  end
end
