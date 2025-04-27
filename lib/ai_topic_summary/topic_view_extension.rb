# frozen_string_literal: true
module AiTopicSummary
  module TopicViewExtension

    def summary(opts = {})
      if SiteSetting.ai_topic_summary_enabled &&
        SiteSetting.ai_topic_summary_enable_description_replacement_with_ai_summary &&
        self.topic.custom_fields.dig("ai_summary", "text").present?

        self.topic.custom_fields["ai_summary"]["text"]
      else
        super(opts)
      end
    end
  end
end
