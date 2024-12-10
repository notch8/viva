# frozen_string_literal: true
class BookmarksController < ApplicationController
  before_action :authenticate_user!

  def create
    @bookmark = current_user.bookmarks.find_or_create_by(question_id: params[:question_id])
    if @bookmark.save
      redirect_back(fallback_location: authenticated_root_path, notice: t('.success'))
    else
      redirect_back(fallback_location: authenticated_root_path, alert: t('.failure'))
    end
  end

  def destroy
    @bookmark = current_user.bookmarks.find_by(question_id: params[:id])
    if @bookmark&.destroy
      redirect_back(fallback_location: authenticated_root_path, notice: t('.success'))
    else
      redirect_back(fallback_location: authenticated_root_path, alert: t('.failure'))
    end
  end

  def destroy_all
    current_user.bookmarks.destroy_all if current_user.bookmarks.present?
    redirect_back(fallback_location: authenticated_root_path, notice: t('.success'))
  end
end
