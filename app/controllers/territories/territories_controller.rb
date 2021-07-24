# frozen_string_literal: true

class Territories::TerritoriesController < ApplicationController
  private

  def territory
    @territory ||= Db::Territory.find(params[:id])
  end
end
