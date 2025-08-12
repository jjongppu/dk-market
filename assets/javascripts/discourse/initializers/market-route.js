import Router from "discourse/router";

export default {
  name: "dk-market-route",
  initialize() {
    Router.map(function () {
      this.route("market", { path: "/market" });
    });
  },
};
