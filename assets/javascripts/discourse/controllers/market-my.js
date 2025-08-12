// assets/javascripts/discourse/controllers/market-my.js
import Controller from "@ember/controller";
import { action } from "@ember/object";
import { ajax } from "discourse/lib/ajax";

export default class MarketMyController extends Controller {
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
      this.model.forEach((group) => {
        if (group.category === item.category) {
          group.items.forEach((i) => {
            i.is_used = i.inventory_id === item.inventory_id;
          });
        }
      });
    }
  }
}
