import DiscourseRoute from "discourse/routes/discourse";
import { ajax } from "discourse/lib/ajax";

export default class MarketRoute extends DiscourseRoute {
  model() {
    // 서버에서 /market/items 호출 → JSON 데이터 반환
    return ajax("/market/items").then((json) => {
      return json.items;
    });
  }
}
