# frozen_string_literal: true

require_dependency "dk_market/market_controller"
require_dependency "dk_market/admin_controller"

DkMarket::Engine.routes.draw do
  get "/market" => "market#index"
  get "/market/items" => "market#items"
  get "/market/items/:id" => "market#show"
  post "/market/purchase" => "market#purchase"
  get "/market/my_item" => "market#my_item"
  post "/market/use" => "market#use"
  post "/market/unuse" => "market#unuse"
end

Discourse::Application.routes.append do
  mount ::DkMarket::Engine, at: "/"

  constraints StaffConstraint.new do
    get "/admin/market_admin" => "dk_market/admin#index"
    get "/admin/market_admin/items" => "dk_market/admin#index"
    post "/admin/market_admin/items" => "dk_market/admin#create"
    put "/admin/market_admin/items/:id" => "dk_market/admin#update"
    delete "/admin/market_admin/items/:id" => "dk_market/admin#destroy"
  end
end
