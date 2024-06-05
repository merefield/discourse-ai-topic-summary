# frozen_string_literal: true

class CreateAiTopicSummaryTagEmbeddingsIndex < ActiveRecord::Migration[7.0]
  def up
    execute <<-SQL
      CREATE INDEX pgv_hnsw_index_on_ai_topic_summary_tag_embeddings ON ai_topic_summary_tag_embeddings USING hnsw (embedding vector_cosine_ops)
      WITH (m = 16, ef_construction = 32);
    SQL
  end

  def down
    execute <<-SQL
      DROP INDEX IF EXISTS pgv_hnsw_index_on_ai_topic_summary_tag_embeddings;
    SQL
  end
end
