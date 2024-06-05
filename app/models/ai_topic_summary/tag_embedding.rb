# frozen_string_literal: true

module ::AiTopicSummary
  class TagEmbedding < ActiveRecord::Base
    self.table_name = 'ai_topic_summary_tag_embeddings'

    validates :tag_id, presence: true, uniqueness: true
  end
end
