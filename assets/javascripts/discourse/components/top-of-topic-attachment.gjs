import Component from "@glimmer/component";
import { service } from "@ember/service";
import AiTopicSummary from "./ai-topic-summary";

export default class TopOfTopicAttachment extends Component {
  @service siteSettings;

  get relyOnSidebarWidgetInstead() {
    return this.siteSettings.ai_topic_summary_rely_on_sidebar_widget_instead;
  }

  <template>
    {{#unless this.relyOnSidebarWidgetInstead}}
      <AiTopicSummary
        @text={{@model.ai_summary.text}}
        @topic_id={{@model.id}}
        @downVotes={{@model.ai_summary.downvoted}}
        @currentUser={{@currentUser}}
      />
    {{/unless}}
  </template>
}
