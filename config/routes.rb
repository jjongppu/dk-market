# frozen_string_literal: true

DkMarket::Engine.routes.draw do
  get "/examples" => "examples#index"
  # define routes here
end

Discourse::Application.routes.draw { mount ::DkMarket::Engine, at: "dk-market" }
