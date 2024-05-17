# frozen_string_literal: true

# Job is potentially triggered by a Post Create event

class ::Jobs::AiTopicSummarySummariseTopic < Jobs::Base
  sidekiq_options retry: 5

  def execute(opts)
    topic_id = opts[:topic_id]

    ::AiTopicSummary::Summarise.retrieve_and_post_summary(topic_id)
  end
end
