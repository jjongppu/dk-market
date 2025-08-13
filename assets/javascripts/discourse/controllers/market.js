// assets/javascripts/discourse/controllers/market.js
import Controller from "@ember/controller";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";

export default class MarketController extends Controller {
  @tracked activeTab = "shop";

  @action
  selectTab(tab) {
    this.activeTab = tab;
  }
}
