# frozen_string_literal: true

# Job is triggered on an update to a Post.
class ::Jobs::AiTopicSummaryTagEmbedding < Jobs::Base
  sidekiq_options retry: 5, dead: false, queue: 'low'

  def execute(opts)
    begin
      tag_id = opts[:id]

      ::AiTopicSummary.progress_debug_message("100. Creating/updating a Tag Embedding for Tag id: #{tag_id}")

      process_topic_title_embedding = ::AiTopicSummary::TagEmbeddingProcess.new

      process_topic_title_embedding.upsert(tag_id)
    rescue => e
      Rails.logger.error("AI Topic Summary: Tag Embedding: There was a problem, but will retry til limit: #{e}")
    end
  end
end
