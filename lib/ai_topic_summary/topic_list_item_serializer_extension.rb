# frozen_string_literal: true

module AiTopicSummary
  module TopicListItemSerializerExtension

    def excerpt
      if object.custom_fields['ai_summary'].present? && object.custom_fields['ai_summary']["text"].present? && !object.custom_fields['ai_summary']["text"].blank? && SiteSetting.ai_topic_summary_expose_as_excerpt
        PrettyText.excerpt(object.custom_fields['ai_summary']["text"], 300, keep_emoji_images: true)
      else
        object.excerpt
      end
    end

  end
end
