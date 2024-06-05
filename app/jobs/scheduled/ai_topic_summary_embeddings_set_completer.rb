# frozen_string_literal: true
class ::Jobs::AiTopicSummaryEmbeddingsSetCompleter < ::Jobs::Scheduled
  sidekiq_options retry: false

  every 24.hours

  def execute(args)
    return if !SiteSetting.ai_topic_summary_auto_tagging_embeddings_enabled

    ::AiTopicSummary::EmbeddingCompletionist.process
  end
end
