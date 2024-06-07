# frozen_string_literal: true

class Territories::PhoneListTerritoriesController < Territories::TerritoriesController
  model_class Db::PhoneListTerritory

  def xls
    spreadsheet = PhoneListTerritoryService.new.create_spreadsheet(territory)
    send_data(spreadsheet.to_stream.read, filename: territory.filename('xls'))
  end

  def pdf
    @component = Territories::PhoneListPdfComponent.new(territory:)
    options = { orientation: 'Landscape' }

    if token_present?
      options[:disposition] = 'attachment'
    end

    export_pdf(territory.filename, options)
  end

  def create_token
    token = Db::AccessToken.for(territory)
    render show_component(record).with_access_token(token)
  end

  private

  def require_authorization
    if token_candidate? && token_present?
      return validate_token
    end

    super
  end

  def territory
    @territory ||= Db::PhoneListTerritory.find(params[:id])
  end

  def validate_token
    token = Db::AccessToken.find_by(token: params[:access_token])
    unless token.valid_for?(territory)
      raise ActiveRecord::RecordNotFound
    end
  end

  def token_candidate?
    %i[xls pdf].include?(params[:action].to_sym)
  end

  def token_present?
    params[:access_token].present?
  end
end
