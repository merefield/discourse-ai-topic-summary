class ::AITopicSummary::Summarise
  
  def self.return_summary(topic_id)
    raw = self.get_markdown(topic_id)
    summary = ::AITopicSummary::CallBot.get_response(raw)
  end

  def self.get_markdown(topic_id)
    # opts = params.slice(:page)
    # opts[:limit] = MARKDOWN_TOPIC_PAGE_SIZE
    topic_view = TopicView.new(topic_id)
    content = topic_view.posts.map { |p| <<~MD }
        #{p.user.username} | #{p.updated_at} | ##{p.post_number}
        #{p.raw}
        -------------------------
      MD
    content.join
  end
end
