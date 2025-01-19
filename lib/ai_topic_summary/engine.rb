# frozen_string_literal: true
module ::AiTopicSummary
  class Engine < ::Rails::Engine
    engine_name PLUGIN_NAME
    isolate_namespace AiTopicSummary
    config.autoload_paths << File.join(config.root, "lib")
  end
end
