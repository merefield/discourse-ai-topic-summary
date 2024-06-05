# frozen_string_literal: true
require "openai"

module ::AiTopicSummary

  class EmbeddingCompletionist

    def self.process
      process_tags
    end

    def self.process_tags
      ::Tag.all.each do |tag|
        ::Jobs.enqueue(:ai_topic_summary_tag_embedding, id: tag.id)
      end

      TagEmbedding.where.not(tag_id: ::Tag.all.pluck(:id)).destroy_all

      ::AiTopicSummary.progress_debug_message <<~EOS
      ---------------------------------------------------------------------------------------------------------------
      Refreshed embeddings for: #{::Tag.count} tags
      ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      EOS
    end
  end
end
