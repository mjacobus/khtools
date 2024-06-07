# frozen_string_literal: true

class Territories::ContactsController < ApplicationController
  def index
    render Territories::Contacts::IndexPageComponent.new(territory:)
  end

  def new
    contact = territory.contacts.build
    render form_for(contact)
  end

  def edit
    render form_for(contact)
  end

  def create
    contact = territory.contacts.build
    contact.attributes = contact_params

    if contact.save
      territory.contacts << contact
      redirect_to(action: :index)
      return
    end

    render form_for(contact), status: :unprocessable_entity
  end

  def update
    if contact.update(contact_params)
      redirect_to(action: :index)
      return
    end

    render form_for(contact), status: :unprocessable_entity
  end

  def destroy
    contact.destroy
    redirect_to(action: :index)
  end

  private

  def contact
    @contact ||= territory.contacts.find(params[:id])
  end

  def territory
    @territory ||= Db::CommercialTerritory.find(params[:commercial_territory_id])
  end

  def contact_params
    params.require(:contact).permit(:name, :address, :email, :phone, :phone2, :notes)
  end

  def form_for(contact)
    Territories::Contacts::FormPageComponent.new(
      territory:,
      contact:
    )
  end
end
