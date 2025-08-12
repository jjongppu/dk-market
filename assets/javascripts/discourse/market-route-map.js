export default function () {
  this.route("market", { path: "/market" }, function () {
    this.route("my", { path: "/my" });
  });
}
