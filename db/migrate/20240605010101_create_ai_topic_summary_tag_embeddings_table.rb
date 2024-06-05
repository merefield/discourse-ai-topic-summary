# frozen_string_literal: true

class CreateAiTopicSummaryTagEmbeddingsTable < ActiveRecord::Migration[7.0]
  def change
    create_table :ai_topic_summary_tag_embeddings do |t|
      t.integer :tag_id, null: false, index: { unique: true }, foreign_key: true
      t.column :embedding, "vector(1536)", null: false
      t.column :model, :string, default: nil
      t.timestamps
    end
  end
end
