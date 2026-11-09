# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :require_master_user

  def index
    @users = User.order(:email)
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if save_user
      redirect_to users_path, notice: "#{@user.name} salvo."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  # The publisher link lives on the publisher: unlink the old one, save, link the new one.
  def save_user
    publisher_id = params.dig(:user, :publisher_id).presence
    User.transaction do
      unlink_publishers(except: publisher_id)
      @user.update!(params.require(:user).permit(:enabled, :master, :account_id,
                                                 controller_accesses: []))
      @user.account&.publishers&.find_by(id: publisher_id)&.update!(user: @user)
    end
    true
  rescue ActiveRecord::RecordInvalid
    false
  end

  def unlink_publishers(except:)
    Db::Publisher.where(user_id: @user.id).where.not(id: except)
      .update_all(user_id: nil) # rubocop:disable Rails/SkipsModelValidations
    @user.association(:publisher).reset
  end

  def require_master_user
    unless current_user.master?
      redirect_to('/')
    end
  end
end
