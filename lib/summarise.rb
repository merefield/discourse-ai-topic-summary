class ::AiTopicSummary::Summarise
  
  def self.return_summary(topic_id)
    raw = self.get_markdown(topic_id)
    summary = ::AiTopicSummary::CallBot.get_response(raw)
  end

  def self.get_markdown(topic_id)
    # original markdown, experiment!
    # #{p.user.username} | #{p.updated_at} | ##{p.post_number}
    # -------------------------
    topic_view = TopicView.new(topic_id)
    content = topic_view.posts.map { |p| <<~MD }
        #{p.user.username}
        #{p.raw}
        --
      MD
    result = content.join[0..SiteSetting.ai_topic_summary_character_limit]
    result[0...result.rindex(' ')] << "."
  end
end
