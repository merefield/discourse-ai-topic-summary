import Component from '@glimmer/component';
import { inject as service } from "@ember/service";

export default class TopOfTopicAttachment extends Component {
  @service siteSettings;

  get relyOnLayoutsWidgetInstead() {
    return this.siteSettings.ai_topic_summary_rely_on_layouts_widget_instead
  }
}
