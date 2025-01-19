# frozen_string_literal: true

module ::AiTopicSummary
  class TagEmbedding < ActiveRecord::Base
    self.table_name = 'ai_topic_summary_tag_embeddings'

    validates :tag_id, presence: true, uniqueness: true
  end
end

# == Schema Information
#
# Table name: ai_topic_summary_tag_embeddings
#
#  id         :bigint           not null, primary key
#  tag_id     :integer          not null
#  embedding  :vector(1536)     not null
#  model      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_ai_topic_summary_tag_embeddings_on_tag_id    (tag_id) UNIQUE
#  pgv_hnsw_index_on_ai_topic_summary_tag_embeddings  (embedding) USING hnsw
#
