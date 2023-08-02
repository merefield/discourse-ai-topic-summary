# frozen_string_literal: true
require "openai"

class ::AiTopicSummary::CallBot
  # see https://github.com/alexrudall/ruby-openai
  def self.get_response(prompt)

    client = OpenAI::Client.new(access_token: SiteSetting.ai_topic_summary_open_ai_token)

    model_name = SiteSetting.ai_topic_summary_open_ai_model_custom ? SiteSetting.ai_topic_summary_open_ai_model_custom_name : SiteSetting.ai_topic_summary_open_ai_model

    if ["gpt-3.5-turbo", "gpt-4"].include?(SiteSetting.ai_topic_summary_open_ai_model) ||
      (SiteSetting.ai_topic_summary_open_ai_model_custom == true && SiteSetting.ai_topic_summary_open_ai_model_custom_type == "chat")

      response = client.chat(
        parameters: {
            model: model_name,
            messages: prompt,
            max_tokens: SiteSetting.ai_topic_summary_request_max_response_tokens,
            temperature: SiteSetting.ai_topic_summary_request_temperature / 100.0,
            top_p: SiteSetting.ai_topic_summary_request_top_p / 100.0,
            frequency_penalty: SiteSetting.ai_topic_summary_request_frequency_penalty / 100.0,
            presence_penalty: SiteSetting.ai_topic_summary_request_presence_penalty / 100.0
        })

      if response["error"]
        begin
          raise StandardError, response["error"]["message"]
        rescue => e
          Rails.logger.error ("AI Topic Summary: There was a problem: #{e}")
          I18n.t('ai_topic_summary.errors.general')
        end
      else
        response.dig("choices", 0, "message", "content")
      end
    elsif (SiteSetting.ai_topic_summary_open_ai_model_custom == true && SiteSetting.ai_topic_summary_open_ai_model_custom_type == "completions") ||
      ["text-davinci-003", "text-davinci-002"].include?(SiteSetting.ai_topic_summary_open_ai_model)

      response = client.completions(
        parameters: {
            model: model_name,
            prompt: prompt,
            max_tokens: SiteSetting.ai_topic_summary_request_max_response_tokens,
            temperature: SiteSetting.ai_topic_summary_request_temperature / 100.0,
            top_p: SiteSetting.ai_topic_summary_request_top_p / 100.0,
            frequency_penalty: SiteSetting.ai_topic_summary_request_frequency_penalty / 100.0,
            presence_penalty: SiteSetting.ai_topic_summary_request_presence_penalty / 100.0
        })

      if response.parsed_response["error"]
        begin
          raise StandardError, response.parsed_response["error"]["message"]
        rescue => e
          Rails.logger.error ("AI Topic Summary: There was a problem: #{e}")
          I18n.t('ai_topic_summary.errors.general')
        end
      else
        response["choices"][0]["text"]
      end
    end
  end
end
