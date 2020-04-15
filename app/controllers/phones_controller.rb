# frozen_string_literal: true

class PhonesController < ApplicationController
  def index
    @phones = territory.phones
  end

  def create
    territory.create_phones(params[:phone_numbers].split("\n"))
    redirect_to action: :index
  end

  def destroy
    phone.destroy
    redirect_to action: :index
  end

  private

  def phone
    territory.phones.find(params[:id])
  end

  def territory
    @territory ||= Territory.find(params[:territory_id])
  end
end
