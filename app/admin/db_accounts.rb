# frozen_string_literal: true

ActiveAdmin.register Db::Account do
  permit_params :congregation_name,
                :territory_map,
                :cloudinary_cloud_name,
                :cloudinary_api_key,
                :cloudinary_api_secret

  form do |f|
    f.semantic_errors
    f.inputs do
      f.input :congregation_name
      f.input :territory_map
      f.input :cloudinary_cloud_name
      f.input :cloudinary_api_key
      f.input :cloudinary_api_secret
    end
    f.actions
  end
end
