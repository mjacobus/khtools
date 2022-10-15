# frozen_string_literal: true

ActiveAdmin.register Db::Account do
  permit_params :congregation_name, :territory_map
end
