# frozen_string_literal: true
require "openai"

module ::AiTopicSummary

  class EmbeddingProcess

    def setup_api
      ::OpenAI.configure do |config|
        config.access_token = SiteSetting.ai_topic_summary_open_ai_token
      end
      if !SiteSetting.chatbot_open_ai_embeddings_model_custom_url.blank?
        ::OpenAI.configure do |config|
          config.uri_base = SiteSetting.chatbot_open_ai_embeddings_model_custom_url
        end
      end
      if SiteSetting.chatbot_open_ai_model_custom_api_type == "azure"
        ::OpenAI.configure do |config|
          config.api_type = :azure
          config.api_version = SiteSetting.chatbot_open_ai_model_custom_api_version
        end
      end
      @model_name = SiteSetting.chatbot_open_ai_embeddings_model
      @client = ::OpenAI::Client.new
    end

    def upsert(id)
      raise "Overwrite me!"
    end

    def get_embedding_from_api(id)
      raise "Overwrite me!"
    end


    def semantic_search(query)
      raise "Overwrite me!"
    end
  end
end
