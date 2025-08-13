import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";

export default class MarketMyComponent extends Component {
  @tracked items = null;
  @tracked isLoading = false;
  @tracked togglingId = null;
  @tracked cooldownIds = [];
  @tracked refreshCooling = false;

  constructor() {
    super(...arguments);
    this.loadItems();
  }

  async loadItems() {
    this.isLoading = true;
    try {
      const json = await ajax("/market/my_items");
      this.items = this._groupByCategory(json.items || []);
    } catch (e) {
      popupAjaxError(e);
      this.items = [];
    } finally {
      this.isLoading = false;
    }
  }

  _groupByCategory(items = []) {
    const groups = {};
    items.forEach((item) => {
      const cat = item.category || "기타";
      (groups[cat] ||= []).push(item);
    });

    return Object.keys(groups)
      .sort((a, b) => a.localeCompare(b))
      .map((category) => ({
        category,
        items: groups[category].sort((a, b) =>
          (a.name || "").localeCompare(b.name || "")
        ),
      }));
  }

  @action
  async refresh() {
    if (this.refreshCooling) {
      return;
    }
    this.refreshCooling = true;
    await this.loadItems();
    setTimeout(() => {
      this.refreshCooling = false;
    }, 3000);
  }

  @action
  async toggleUse(item) {
    if (
      this.togglingId ||
      this.cooldownIds.includes(item.inventory_id)
    ) {
      return;
    }
    this.togglingId = item.inventory_id;
    try {
      if (item.is_used) {
        await ajax("/market/unuse", {
          type: "POST",
          data: { inventory_id: item.inventory_id },
        });
        this.items = this.items.map((group) => {
          if (group.category !== item.category) return group;
          return {
            ...group,
            items: group.items.map((i) =>
              i.inventory_id === item.inventory_id ? { ...i, is_used: false } : i
            ),
          };
        });
      } else {
        await ajax("/market/use", {
          type: "POST",
          data: { inventory_id: item.inventory_id },
        });
        this.items = this.items.map((group) => {
          if (group.category !== item.category) return group;
          return {
            ...group,
            items: group.items.map((i) => ({
              ...i,
              is_used: i.inventory_id === item.inventory_id,
            })),
          };
        });
      }
    } catch (e) {
      popupAjaxError(e);
    } finally {
      this.togglingId = null;
      this.cooldownIds = [...this.cooldownIds, item.inventory_id];
      setTimeout(() => {
        this.cooldownIds = this.cooldownIds.filter(
          (id) => id !== item.inventory_id
        );
      }, 3000);
    }
  }
}
