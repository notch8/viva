# frozen_string_literal: true
require 'nokogiri'

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
      @questions = Question.filter(**filter_values)

      if any_question_has_images?
        serve_zip_file(filename)
      else
        serve_xml_file(filename)
      end
    else
      render inertia: 'Search', props: shared_props
    end
  end

  def download_as_plain_text
    questions = Bookmark.pluck(:question_id).map{|q| Question.where(id: q)}.flatten
    content = []
    questions.map do |question|
      if question.type == 'Question::Essay' || question.type == 'Question::Upload'
        content << essay_type(question)
        content << "\n\n**********\n\n"
      elsif question.type == 'Question::Traditional' || question.type == 'Question::SelectAllThatApply' || question.type == 'Question::DragAndDrop'
        content << traditional_type(question)
        content << "\n**********\n\n"
      elsif question.type == 'Question::Matching'
        content << matching_type(question)
        content << "\n**********\n\n"
      elsif question.type == 'Question::Categorization'
        content << categorization_type(question)
        content << "**********\n\n"
      elsif question.type == 'Question::BowTie'
        content << bowtie_type(question)
        content << "\n**********\n\n"
      elsif question.type == 'Question::StimulusCaseStudy'
        content << stimulus_type(question)
        content << "**********\n\n"
      end
    end
    content = content.join('')
    send_data content, filename: 'questions.txt', type: 'text/plain'
  end

  private

  def essay_type(question)
    question_type = question.type.slice(10..-1).titleize
    
    # Formats HTML into plain text
    rich_text = Nokogiri::HTML(question.data['html'])
    rich_text.css('a').each do |link_tag|
      link_tag.replace("#{link_tag.text} (#{link_tag['href']})")
    end
    rich_text.css('p').each do |p_tag|
      p_tag.replace("#{p_tag.text}\n")
    end
    rich_text.css('li').each do |li_tag|
      li_tag.replace("- #{li_tag.text}\n")
    end
    plain_text = rich_text.text.strip
    "Question Type: #{question_type}\nQuestion: #{question.text}\n\nText: #{plain_text}"
  end

  def traditional_type(question)
    question_type = question.type.slice(10..-1).titleize
    # The preferred name for Traditional questions is "Multiple Choice"
    if question.type == 'Question::Traditional'
      question_type = 'Multiple Choice'
    end

    data = question.data.map.with_index do |answer_set, index|
      "#{index + 1}) #{if answer_set['correct'] then 'Correct' else 'Incorrect' end}: #{answer_set['answer']}\n"
    end.join('')
    "Question Type: #{question_type}\nQuestion: #{question.text}\n\n#{data}"
  end

  def matching_type(question)
    question_type = question.type.slice(10..-1).titleize
    data = question.data.map.with_index do |answer_set, index|
      "#{index + 1}) #{answer_set['answer']}\n   Correct Match: #{answer_set['correct'].first}\n"
    end.join('')
    "Question Type: #{question_type}\nQuestion: #{question.text}\n\n#{data}"
  end

  def categorization_type(question)
    question_type = question.type.slice(10..-1).titleize
    data = question.data.map do |answer_set|
      "Catagory: #{answer_set['answer']}\n#{answer_set['correct'].map.with_index { |c, index| "#{index + 1}) #{c}\n" }.join('')}\n"
    end.join('')
    "Question Type: #{question_type}\nQuestion: #{question.text}\n\n#{data}"
  end

  def bowtie_type(question)
    question_type = question.type.slice(10..-1).titleize
    center = question.data['center']['answers'].map.with_index do |answer_set, index|
      "#{index + 1}) #{if answer_set['correct'] then 'Correct' else 'Incorrect' end}: #{answer_set['answer']}\n"
    end
    left = question.data['left']['answers'].map.with_index do |answer_set, index|
      "#{index + 1}) #{if answer_set['correct'] then 'Correct' else 'Incorrect' end}: #{answer_set['answer']}\n"
    end
    right = question.data['right']['answers'].map.with_index do |answer_set, index|
      "#{index + 1}) #{if answer_set['correct'] then 'Correct' else 'Incorrect' end}: #{answer_set['answer']}\n"
    end
    data = "Center\n#{center.join('')}\nLeft\n#{left.join('')}\nRight\n#{right.join('')}"
    "Question Type: #{question_type}\nQuestion: #{question.text}\n\n#{data}"
  end

  def stimulus_type(question)
    question_type = question.type.slice(10..-1).titleize
    output = []
    question.child_questions.map do |sub_question|
      if sub_question.type == "Question::Scenario"
        output << "Scenario: #{sub_question.text}\n\n"
      elsif sub_question.type == "Question::Essay" || sub_question.type == "Question::Upload"
        output << "#{essay_type(sub_question)}\n"
      elsif sub_question.type == "Question::Traditional" || sub_question.type == "Question::SelectAllThatApply" || sub_question.type == "Question::DragAndDrop"
        output << "#{traditional_type(sub_question)}\n"
      elsif sub_question.type == "Question::Matching"
        output << "#{matching_type(sub_question)}\n"
      elsif sub_question.type == "Question::Categorization"
        output << "#{categorization_type(sub_question)}\n"
      elsif sub_question.type == "Question::BowTie"
        output << "#{bowtie_type(sub_question)}\n"
      end
    end
    "Question Type: #{question_type}\nQuestion: #{question.text}\n\n#{output.join('')}\n"
  end

  def any_question_has_images?
    @questions.any? { |question| question.images.any? }
  end

  def serve_zip_file(xml_filename)
    xml_content = render_to_string(format: :xml)
    images = @questions.flat_map(&:images)
    zip_file_service = ZipFileService.new(images, xml_content, xml_filename)
    temp_file = zip_file_service.generate_zip
    zip_filename = xml_filename.gsub('.xml', '.zip')

    send_file(temp_file.path, filename: zip_filename)
  end

  def serve_xml_file(filename)
    # Set the 'Content-Disposition' as 'attachment' so that instead of showing the XML file in the
    # browser, we instead tell the browser to automatically download this file.
    response.headers['Content-Disposition'] = %(attachment; filename="#{filename}")
    render format: :xml
  end

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
      exportHrefs: export_hrefs,
      bookmarkedQuestionIds: current_user.bookmarks.pluck(:question_id)
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
      bookmarked_question_ids: params[:bookmarked_question_ids],
      bookmarked: ActiveModel::Type::Boolean.new.cast(params[:bookmarked]),
      user: current_user
    }
  end
end
