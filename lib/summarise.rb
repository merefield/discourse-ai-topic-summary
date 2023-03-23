# frozen_string_literal: true
class ::AiTopicSummary::Summarise
  
  def self.retrieve_summary(topic_id)
    raw = self.get_markdown(topic_id)
    summary = ::AiTopicSummary::CallBot.get_response(raw)
    current_topic = Topic.find(topic_id)
    current_topic.custom_fields["ai_summary"] = {"text": summary, "post_count":current_topic.posts_count, "downvoted": []}
    current_topic.save!
  end

  def self.get_markdown(topic_id)
    system_user = User.find(-1)
    topic_view = TopicView.new(topic_id, system_user)
    content = []
    topic_view.posts.each_with_index do |p, index|
      next if p.post_type > 1
      break if index > SiteSetting.ai_topic_summary_post_limit
      content << I18n.t("ai_topic_summary.prompt.post", username: p.user.username, raw: p.raw)
    end
    result = content.join
    result = result[0..SiteSetting.ai_topic_summary_character_limit]
    result[0...result.rindex('.')] << "."
  end
end
