// assets/javascripts/discourse/components/market-my.js
import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";

export default class MarketMyComponent extends Component {
  @tracked items = [];            // 카테고리별 그룹 [{ category, items: [] }, ...]
  @tracked isLoading = false;
  @tracked togglingId = null;
  @tracked cooldownIds = [];      // inventory_id 배열
  @tracked refreshCooling = false;

  _cooldownTimers = new Map();

  constructor() {
    super(...arguments);
    this.loadItems();
  }

  willDestroy() {
    super.willDestroy?.();
    for (const [, t] of this._cooldownTimers) clearTimeout(t);
    this._cooldownTimers.clear();
  }

  _applyCooldownFlags(groups) {
    const set = new Set(this.cooldownIds || []);
    return (groups || []).map((g) => ({
      ...g,
      items: (g.items || []).map((i) => ({ ...i, _cooldown: set.has(i.inventory_id) })),
    }));
  }

  async loadItems() {
    this.isLoading = true;
    try {
      const json = await ajax("/market/my_items");
      const byCat = {};
      (json?.items || []).forEach((it) => {
        const c = it?.category || "기타";
        (byCat[c] ||= []).push(it);
      });
      const grouped = Object.keys(byCat)
        .sort((a, b) => a.localeCompare(b))
        .map((category) => ({
          category,
          items: byCat[category].sort((a, b) => (a?.name || "").localeCompare(b?.name || "")),
        }));
      this.items = this._applyCooldownFlags(grouped);
    } catch (e) {
      popupAjaxError(e);
      this.items = [];
    } finally {
      this.isLoading = false;
    }
  }

  @action
  async refresh() {
    if (this.refreshCooling) return;
    this.refreshCooling = true;
    await this.loadItems();
    const t = setTimeout(() => {
      this.refreshCooling = false;
      this._cooldownTimers.delete("__refresh__");
    }, 3000);
    this._cooldownTimers.set("__refresh__", t);
  }

  @action
  async toggleUse(item) {
    const invId = item?.inventory_id;
    if (!invId) return;
    if (this.togglingId) return; // 진행 중이면 무시

    this.togglingId = invId;
    try {
      if (item.is_used) {
        await ajax("/market/unuse", { type: "POST", data: { inventory_id: invId } });
        const cat = item.category;
        this.items = this.items.map((g) =>
          g.category === cat
            ? { ...g, items: g.items.map((i) => (i.inventory_id === invId ? { ...i, is_used: false } : i)) }
            : g
        );
      } else {
        await ajax("/market/use", { type: "POST", data: { inventory_id: invId } });
        const cat = item.category;
        this.items = this.items.map((g) =>
          g.category === cat
            ? { ...g, items: g.items.map((i) => ({ ...i, is_used: i.inventory_id === invId })) }
            : g
        );
      }
    } catch (e) {
      popupAjaxError(e);
    } finally {
      this.togglingId = null;

      // 쿨다운 추가
      if (!(this.cooldownIds || []).includes(invId)) {
        this.cooldownIds = [...(this.cooldownIds || []), invId];
      }
      // 아이템 플래그 업데이트
      this.items = this._applyCooldownFlags(this.items);

      // 타이머 갱신
      const old = this._cooldownTimers.get(invId);
      if (old) clearTimeout(old);
      const t = setTimeout(() => {
        this.cooldownIds = (this.cooldownIds || []).filter((id) => id !== invId);
        this.items = this._applyCooldownFlags(this.items);
        this._cooldownTimers.delete(invId);
      }, 3000);
      this._cooldownTimers.set(invId, t);
    }
  }
}
