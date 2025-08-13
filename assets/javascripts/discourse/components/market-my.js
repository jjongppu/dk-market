import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";

export default class MarketMyComponent extends Component {
  @tracked items = [];          // ← null 대신 빈 배열로
  @tracked isLoading = false;
  @tracked togglingId = null;
  @tracked cooldownIds = [];
  @tracked refreshCooling = false;

  // cooldown 타이머 관리(컴포넌트 destroy 시 정리)
  _cooldownTimers = new Map();

  constructor() {
    super(...arguments);
    this.loadItems();
  }

  willDestroy() {
    super.willDestroy?.();
    // 등록된 타이머 전부 해제
    for (const [, t] of this._cooldownTimers) {
      clearTimeout(t);
    }
    this._cooldownTimers.clear();
  }

  async loadItems() {
    this.isLoading = true;
    try {
      const json = await ajax("/market/my_items");
      console.log("[market-my] fetched items", json?.items);
      const grouped = this._groupByCategory(json?.items ?? []);
      console.log("[market-my] grouped items", grouped);
      this.items = grouped;
    } catch (e) {
      popupAjaxError(e);
      this.items = [];
    } finally {
      this.isLoading = false;
    }
  }

  _groupByCategory(items = []) {
    const groups = {};
    for (const item of items) {
      console.log("[market-my] processing item", item);
      const cat = item?.category || "기타";
      (groups[cat] ||= []).push(item);
    }

    // 카테고리 정렬(기본: 사전순)
    const cats = Object.keys(groups).sort((a, b) => a.localeCompare(b));
    return cats.map((category) => ({
      category,
      items: (groups[category] || []).sort((a, b) =>
        (a?.name || "").localeCompare(b?.name || "")
      ),
    }));
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
    if (!invId) return; // 방어

    // 이미 처리 중이거나 쿨다운 중이면 무시
    if (this.togglingId || (this.cooldownIds || []).includes(invId)) {
      return;
    }

    this.togglingId = invId;

    try {
      if (item.is_used) {
        await ajax("/market/unuse", {
          type: "POST",
          data: { inventory_id: invId },
        });

        const cat = item.category;
        this.items = (this.items ?? []).map((group) => {
          if (group.category !== cat) return group;
          return {
            ...group,
            items: (group.items ?? []).map((i) =>
              i.inventory_id === invId ? { ...i, is_used: false } : i
            ),
          };
        });
      } else {
        await ajax("/market/use", {
          type: "POST",
          data: { inventory_id: invId },
        });

        const cat = item.category;
        this.items = (this.items ?? []).map((group) => {
          if (group.category !== cat) return group;
          return {
            ...group,
            items: (group.items ?? []).map((i) => ({
              ...i,
              is_used: i.inventory_id === invId,
            })),
          };
        });
      }
    } catch (e) {
      popupAjaxError(e);
    } finally {
      this.togglingId = null;

      // 쿨다운 시작
      if (!(this.cooldownIds || []).includes(invId)) {
        this.cooldownIds = [...(this.cooldownIds || []), invId];
      }

      // 기존 invId 타이머가 있으면 정리 후 재설정
      const old = this._cooldownTimers.get(invId);
      if (old) clearTimeout(old);

      const t = setTimeout(() => {
        this.cooldownIds = (this.cooldownIds || []).filter((id) => id !== invId);
        this._cooldownTimers.delete(invId);
      }, 3000);
      this._cooldownTimers.set(invId, t);
    }
  }
}
