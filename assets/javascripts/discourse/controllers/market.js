import Controller from "@ember/controller";
import { action } from "@ember/object";
import { tracked } from "@glimmer/tracking";
import { ajax } from "discourse/lib/ajax";

export default class MarketController extends Controller {
  @tracked q = "";
  @tracked sort = "";

  get filtered() {
    let items = this.model || [];

    if (this.q) {
      const q = this.q.toLowerCase();
      items = items.filter((item) => item.name.toLowerCase().includes(q));
    }

    if (this.sort === "price") {
      items = items.slice().sort((a, b) => a.price_points - b.price_points);
    } else if (this.sort === "name") {
      items = items.slice().sort((a, b) => a.name.localeCompare(b.name));
    }

    return items;
  }

  @action
  updateSort(event) {
    this.sort = event.target.value;
  }

  @action
  purchase(item) {
    return ajax("/market/purchase", {
      type: "POST",
      data: { item_id: item.id },
    });
  }
}
