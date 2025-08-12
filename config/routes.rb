# frozen_string_literal: true

DkMarket::Engine.routes.draw do
  root to: "market#index"
  get "/items" => "market#items"
  get "/items/:id" => "market#show"
  post "/purchase" => "market#purchase"
  get "/my_items" => "market#my_items"
  post "/use" => "market#use"
  post "/unuse" => "market#unuse"
end

Discourse::Application.routes.append do
  mount ::DkMarket::Engine, at: "/market"
end
