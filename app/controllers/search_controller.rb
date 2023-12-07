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
      filename = "questions-#{now.strftime('%Y-%m-%d_%H:%M:%S:%L')}.qti.xml"
      @questions = Question.filter(**filter_values)

      # Set the 'Content-Disposition' as 'attachment' so that instead of showing the XML file in the
      # browser, we instead tell the browser to automatically download this file.
      response.headers['Content-Disposition'] = %(attachment; filename="#{filename}")
      render format: :xml
    else
      render inertia: 'Search', props: shared_props
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
      filteredQuestions: Question.filter_as_json(**filter_values),
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
      levels: params[:selected_levels]
    }
  end
end
