# frozen_string_literal: true

##
# The controller to handle methods related to the search page.
class SearchController < ApplicationController
  XML_PREAMBLE = %(<?xml version="1.0" encoding="UTF-8"?>)
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
      # Don't forget the pre-amble
      xml = XML_PREAMBLE
      Question.filter(**filter_values).each do |q|
        xml += "#{q.to_xml}\n"
      end
      send_data xml, layout: false, filename: "questions-#{Time.current.strftime('%Y-%m-%d_%H:%M:%S')}.qti.xml", format: :xml
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

  def search_params
    params.permit(:selected_keywords, :selected_subjects, :selected_types, :selected_levels)
  end
end
