import DiscourseRoute from "discourse/routes/discourse";
import { ajax } from "discourse/lib/ajax";

export default class MarketRoute extends DiscourseRoute {
  async model() {
    const json = await ajax("/market/items");
    return json.items || [];
  }
}
