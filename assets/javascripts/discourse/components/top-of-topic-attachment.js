import Component from '@glimmer/component';
import { inject as service } from "@ember/service";

export default class TopOfTopicAttachment extends Component {
  @service siteSettings;

  get relyOnSidebarWidgetInstead() {
    return this.siteSettings.ai_topic_summary_rely_on_sidebar_widget_instead
  }
}
