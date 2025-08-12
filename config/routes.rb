# frozen_string_literal: true

require_dependency "market/market_controller"
require_dependency "market/admin_controller"

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
    get "/admin/market_admin" => "market/admin#index"
    get "/admin/market_admin/items" => "market/admin#index"
    post "/admin/market_admin/items" => "market/admin#create"
    put "/admin/market_admin/items/:id" => "market/admin#update"
    delete "/admin/market_admin/items/:id" => "market/admin#destroy"
  end
end
