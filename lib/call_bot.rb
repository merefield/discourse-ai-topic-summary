# frozen_string_literal: true
require "openai"

class OpenAICallError < StandardError
  attr_reader :foo

  def initialize(foo)
   super
   @foo = foo
  end
end

class ::AiTopicSummary::CallBot
  # see https://github.com/alexrudall/ruby-openai
  def self.get_response(full_raw)

    # TODO add this in when support added via PR after "ruby-openai", '3.3.0'
    # OpenAI.configure do |config|
    #   config.request_timeout = 25
    # end

    client = OpenAI::Client.new(access_token: SiteSetting.ai_topic_summary_open_ai_token)

    response = client.completions(
      parameters: {
          model: SiteSetting.ai_topic_summary_open_ai_model,
          prompt: "#{SiteSetting.ai_topic_summary_model_prompt} '#{full_raw}'",
          max_tokens: SiteSetting.ai_topic_summary_max_response_tokens
      })

    if response.parsed_response["error"]
      raise StandardError, response.parsed_response["error"]["message"]
    end

    final_text = response["choices"][0]["text"]

    final_text
  end
end
