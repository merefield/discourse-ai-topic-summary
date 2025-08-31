import Component from "@glimmer/component";
import { service } from "@ember/service";
import TopOfTopicAttachment from "../../components/top-of-topic-attachment";

export default class TopicAbovePostsComponent extends Component {
  @service currentUser;

  <template>
    <TopOfTopicAttachment @model={{@model}} @currentUser={{this.currentUser}} />
  </template>
}
