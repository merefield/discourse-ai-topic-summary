import { createWidget } from 'discourse/widgets/widget';
import { hbs } from "ember-cli-htmlbars";
import RenderGlimmer from "discourse/widgets/render-glimmer";
import DiscourseURL from "discourse/lib/url";

let layouts;

// Import layouts plugin with safegaurd for when widget exists without plugin:
try {
  layouts = requirejs(
    'discourse/plugins/discourse-layouts/discourse/lib/layouts'
  );
} catch (error) {
  layouts = { createLayoutsWidget: createWidget };
  console.warn(error);
}

export default layouts.createLayoutsWidget('ai-topic-summary-widget', {
  tagname: "div.ai-topic-summary-widget",
  buildKey: () => `ai-topic-summary-widget`,

  html(attrs, state) {
    const contents = [];
    const { currentUser } = this;

    contents.push(
      new RenderGlimmer(
        this,
        "div.ai-topic-summary-component",
        hbs`<AiTopicSummary
        @text={{@data.text}}
        @topic_id={{@data.id}}
        @downVotes={{@data.downvoted}}
        @currentUser={{@data.user}}
      />`,
        {
          ...attrs,
          user: currentUser,
          username: currentUser.username,
          text: attrs.topic.ai_summary == null ? undefined : attrs.topic.ai_summary.text,
          id: attrs.topic.id,
          downvoted: attrs.topic.ai_summary == null ? undefined : attrs.topic.ai_summary.downvoted,
        }
      ),
    );
    return contents;
  },
});