# frozen_string_literal: true
require "openai"

class ::AiTopicSummary::CallBot
  # see https://github.com/alexrudall/ruby-openai
  def self.get_response(prompt)
    ::OpenAI.configure do |config|
      config.access_token = SiteSetting.ai_topic_summary_open_ai_token
      config.log_errors = true if SiteSetting.ai_topic_summary_verbose_rails_logging
    end

    client = OpenAI::Client.new do |f|
      f.response :logger, Logger.new($stdout), bodies: true if SiteSetting.ai_topic_summary_verbose_console_logging
      if SiteSetting.ai_topic_summary_verbose_rails_logging
        case SiteSetting.ai_topic_summary_verbose_rails_logging_destination_level
          when "warn"
            f.response :logger, Rails.logger, bodies: true, log_level: :warn
          else
            f.response :logger, Rails.logger, bodies: true, log_level: :info
        end
      end
    end

    model_name = SiteSetting.ai_topic_summary_open_ai_model_custom ? SiteSetting.ai_topic_summary_open_ai_model_custom_name : SiteSetting.ai_topic_summary_open_ai_model

    if ["gpt-3.5-turbo", "gpt-4", "gpt-4-32k", "gpt-4-turbo", "gpt-4o", "gpt-4o-mini"].include?(SiteSetting.ai_topic_summary_open_ai_model) ||
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
      ["gpt-3.5-turbo-instruct"].include?(SiteSetting.ai_topic_summary_open_ai_model)

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

      if response["error"]
        begin
          raise StandardError, response["error"]["message"]
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
