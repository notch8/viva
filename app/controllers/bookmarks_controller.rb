# frozen_string_literal: true
class BookmarksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_bookmark, only: [:destroy]

  def create
    @bookmark = current_user.bookmarks.find_or_create_by(bookmark_params)
    handle_bookmark_action(@bookmark.save, '.success', '.failure')
  end

  def create_batch
    result = Bookmark.create_batch(question_ids: params[:filtered_ids], user: current_user)
    if result == :error
      redirect_back(fallback_location: authenticated_root_path, notice: t('.failure'))
    else
      redirect_back(fallback_location: authenticated_root_path, notice: t('.success'))
    end
  end

  def destroy
    handle_bookmark_action(@bookmark&.destroy, '.success', '.failure')
  end

  def destroy_all
    current_user.bookmarks.destroy_all if current_user.bookmarks.present?
    redirect_back(fallback_location: authenticated_root_path, notice: t('.success'))
  end

  def export
    @bookmarks = current_user.bookmarks.includes(:question)

    if params[:format].in?(%w[canvas blackboard d2l moodle txt md xml viva])
      handle_export
    else
      redirect_to authenticated_root_path, alert: t('.unsupported_format')
    end
  end

  private

  def set_bookmark
    @bookmark = current_user.bookmarks.find_by(question_id: params[:id])
  end

  def bookmark_params
    { question_id: params[:question_id] }
  end

  def handle_bookmark_action(success, success_key, failure_key)
    if success
      redirect_back(fallback_location: authenticated_root_path, notice: t(success_key))
    else
      redirect_back(fallback_location: authenticated_root_path, alert: t(failure_key))
    end
  end

  def handle_export
    export_service = BookmarkExportService.new(@bookmarks)
    export_result = export_service.export(params[:format])

    # We're not expecting thousands of exported question but if
    # that is the case then we want to reconsider this approach
    export_service.questions.each do |question|
      ExportLogger.create(export_type: params[:format], question_id: question.id, user_id: current_user.id)
    end

    if export_result[:is_file]
      send_file(export_result[:data].path,
        filename: export_result[:filename],
        type: export_result[:type])
    else
      send_data export_result[:data],
        filename: export_result[:filename],
        type: export_result[:type]
    end
  end
end
