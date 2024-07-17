# frozen_string_literal: true

##
# The controller to handle methods related to the search page.
class SearchController < ApplicationController
  def index
    # This is a bit different than you might be used to.  Ideally we'd have respond_to behavior.
    #
    # However, inertia behaves differently.  So we have format sniffing instead of the conventional:
    #
    #   respond_to do |wants|
    #     wants.xml { }
    #     wants.inertia { }
    #   end
    #
    # Why? Because inertia is not registered as a mime-type
    if request.format.xml?
      now = Time.current
      @title = "Viva Questions for #{now.strftime('%B %-d, %Y %9N')}"

      # Why the long suffix?  Because Canvas supports both "classic" and "new" format; and per
      # conversations with the client, we're looking to only export classic (as you can migrate a
      # classic question to new format).  This filename is another "helpful clue" and introduces
      # later considerations for what the file format might be.
      filename = "questions-#{now.strftime('%Y-%m-%d_%H:%M:%S:%L')}.classic-question-canvas.qti.xml"
      @questions = Question.filter(**filter_values, user: current_user)

      # Set the 'Content-Disposition' as 'attachment' so that instead of showing the XML file in the
      # browser, we instead tell the browser to automatically download this file.
      response.headers['Content-Disposition'] = %(attachment; filename="#{filename}")
      render format: :xml
    else
      bookmarked_question_ids = current_user.bookmarks.pluck(:question_id) if user_signed_in?
      render inertia: 'Search', props: shared_props.merge(bookmarkedQuestionIds: bookmarked_question_ids)
    end
  end

  private

  # rubocop:disable Metrics/MethodLength
  def shared_props
    {
      keywords: Keyword.names,
      subjects: Subject.names,
      types: Question.type_names, # Deprecated Favor :type_names
      type_names: Question.type_names,
      levels: Level.names,
      selectedKeywords: params[:selected_keywords],
      selectedSubjects: params[:selected_subjects],
      selectedTypes: params[:selected_types],
      selectedLevels: params[:selected_levels],
      filteredQuestions: Question.filter_as_json(**filter_values, user: current_user),
      exportHrefs: export_hrefs
    }
  end
  # rubocop:enable Metrics/MethodLength

  ##
  # @return [Array<Hash<Symbol,String>] the types of exports supported by the {SearchController}.
  def export_hrefs
    [{ type: "xml", href: ".xml#{request.original_fullpath.slice(1..-1)}" }]
  end

  def create_new_export
    # add logic to create an export with the provided filtered questions here once the export model & functionality are created.
    # Export.create(filtered_questions)... etc
  end

  def filter_values
    {
      keywords: params[:selected_keywords],
      subjects: params[:selected_subjects],
      type_name: params[:selected_types],
      levels: params[:selected_levels],
      bookmarked: params[:bookmarked]
    }
  end
end
