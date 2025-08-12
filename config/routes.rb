# frozen_string_literal: true

require_dependency "dk_market/market_controller"
require_dependency "dk_market/admin_controller"

DkMarket::Engine.routes.draw do
  get "/" => "market#index"
  get "/items" => "market#items"
  get "/items/:id" => "market#show"
  post "/purchase" => "market#purchase"
  get "/my_item" => "market#my_item"
  post "/use" => "market#use"
  post "/unuse" => "market#unuse"
end

Discourse::Application.routes.draw do
  mount ::DkMarket::Engine, at: "/market"

  constraints StaffConstraint.new do
    get "/admin/market_admin" => "dk_market/admin#index"
    get "/admin/market_admin/items" => "dk_market/admin#index"
    post "/admin/market_admin/items" => "dk_market/admin#create"
    put "/admin/market_admin/items/:id" => "dk_market/admin#update"
    delete "/admin/market_admin/items/:id" => "dk_market/admin#destroy"
  end
end
