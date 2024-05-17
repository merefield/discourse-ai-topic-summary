# frozen_string_literal: true

# Job is potentially triggered by a Post Create event

class ::Jobs::AiTopicSummarySummariseTopic < Jobs::Base
  sidekiq_options retry: 5

  def execute(opts)
    begin
      topic_id = opts[:topic_id]

      ::AiTopicSummary::Summarise.retrieve_and_post_summary(topic_id)

    rescue => e
      status = e.response[:status]
      message = e.response[:body]["error"]["message"]
      Rails.logger.error("AI Topic Summary: Summarise Job: There was a problem, but will retry til limit: status: #{status}, message: #{message}")
    end
  end
end
