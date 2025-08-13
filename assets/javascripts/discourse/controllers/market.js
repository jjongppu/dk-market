// assets/javascripts/discourse/controllers/market.js
import Controller from "@ember/controller";
import { action } from "@ember/object";
import { ajax } from "discourse/lib/ajax";
import { tracked } from "@glimmer/tracking";

export default class MarketController extends Controller {
  @tracked activeTab = "shop";
  @tracked myItems = null;

  @action
  async selectTab(tab) {
    this.activeTab = tab;
    if (tab === "my" && this.myItems === null) {
      await this.loadMyItems();
    }
  }

  async loadMyItems() {
    const json = await ajax("/market/my_items");
    const groups = {};

    (json.items || []).forEach((item) => {
      const cat = item.category || "기타";
      if (!groups[cat]) {
        groups[cat] = [];
      }
      groups[cat].push(item);
    });

    this.myItems = Object.keys(groups)
      .sort((a, b) => a.localeCompare(b))
      .map((category) => ({
        category,
        items: groups[category].sort((a, b) =>
          (a.name || "").localeCompare(b.name || "")
        ),
      }));
  }

  @action
  async toggleUse(item) {
    if (item.is_used) {
      await ajax("/market/unuse", {
        type: "POST",
        data: { inventory_id: item.inventory_id },
      });
      item.is_used = false;
    } else {
      await ajax("/market/use", {
        type: "POST",
        data: { inventory_id: item.inventory_id },
      });
      this.myItems.forEach((group) => {
        if (group.category === item.category) {
          group.items.forEach((i) => {
            i.is_used = i.inventory_id === item.inventory_id;
          });
        }
      });
    }
  }
}
