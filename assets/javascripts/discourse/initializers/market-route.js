import Router from "discourse/lib/router";

export default {
  name: "dk-market-route",
  initialize() {
    Router.map(function () {
      this.route("market", { path: "/market" });
    });
  },
};
