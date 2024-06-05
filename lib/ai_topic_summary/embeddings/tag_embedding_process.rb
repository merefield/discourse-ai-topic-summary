# frozen_string_literal: true
require "openai"

module ::AiTopicSummary

  class TagEmbeddingProcess < EmbeddingProcess

    def upsert(tag_id)
      if !is_valid(tag_id)
        embedding_vector = get_embedding_from_api(tag_id)

        ::AiTopicSummary::TagEmbedding.upsert({ tag_id: tag_id, model: SiteSetting.ai_topic_summary_auto_tagging_embeddings_model, embedding: "#{embedding_vector}" }, on_duplicate: :update, unique_by: :tag_id)

        ::AiTopicSummary.progress_debug_message <<~EOS
        ---------------------------------------------------------------------------------------------------------------
        Topic Title Embeddings: I found an embedding that needed populating or updating, id: #{tag_id}
        ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        EOS
      end
    end

    def get_embedding_from_api(tag_id)
      begin
        self.setup_api

        embedding_text = ""

        tag = ::Tag.find_by(id: tag_id)

        tag_group = TagGroup.find_by(id: TagGroupMembership.find_by(tag_id: tag_id)&.tag_group_id)

        embedding_text = "Tag Name: '#{tag.name}'" if tag

        embedding_text += " Tag Description: '#{tag.description}'" if tag.description

        embedding_text = "Tag Group: '#{tag_group.name}' #{embedding_text}" if tag_group

        response = @client.embeddings(
          parameters: {
            model: @model_name,
            input: embedding_text
          }
        )

        if response.dig("error")
          error_text = response.dig("error", "message")
          raise StandardError, error_text
        end
      rescue StandardError => e
        Rails.logger.error("AI Topic Summary: Error occurred while attempting to retrieve Embedding for tag id '#{tag_id}': #{e.message}")
        raise e
      end

      embedding_vector = response.dig("data", 0, "embedding")
    end


    def semantic_search(query)
      self.setup_api

      response = @client.embeddings(
        parameters: {
          model: @model_name,
          input: query[0..SiteSetting.ai_topic_summary_auto_tagging_open_ai_embeddings_char_limit]
        }
       )

      query_vector = response.dig("data", 0, "embedding")

      begin
        threshold = SiteSetting.ai_topic_summary_auto_tagging_embeddings_similarity_threshold
        max_tags = SiteSetting.max_tags_per_topic
        results =
          DB.query(<<~SQL, query_embedding: query_vector, threshold: threshold, limit: max_tags)
            SELECT
              tag_id,
              t.name,
              embedding <=> '[:query_embedding]' as cosine_distance
            FROM
              ai_topic_summary_tag_embeddings e
            JOIN
              tags t
            ON
              t.id = e.tag_id
            WHERE
              (1 -  (embedding <=> '[:query_embedding]')) > :threshold
            ORDER BY
              embedding <=> '[:query_embedding]'
            LIMIT :limit
          SQL
      rescue PG::Error => e
        Rails.logger.error(
          "Error #{e} querying embeddings for search #{query}",
        )
        raise MissingEmbeddingError
      end
      results.map { |obj| obj.instance_variable_get(:@name) }
    end

    def is_valid(tag_id)
      embedding_record = ::AiTopicSummary::TagEmbedding.find_by(tag_id: tag_id)
      return false if !embedding_record.present?
      return false if embedding_record.model != SiteSetting.ai_topic_summary_auto_tagging_embeddings_model
      true
    end
  end
end
