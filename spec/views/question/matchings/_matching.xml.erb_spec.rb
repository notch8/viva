# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'question/matchings/_matching' do
  let(:matching) { FactoryBot.build(:question_matching) }
  let(:another_matching) { FactoryBot.build(:question_matching) }

  it 'renders xml' do
    render partial: "question/matchings/matching", locals: { matching: }
    expect(rendered).to include(%(<item ident="#{matching.item_ident}" title="Question #{matching.id}" >))
    # Unlike Question::Categorization; the matching does not allow for multiple.
    # See https://github.com/notch8/viva/issues/237
    expect(rendered).not_to include(%(rcardinality="Multiple">))
    expect(rendered).to include(%(<fieldentry>matching_question</fieldentry>))
  end

  it 'generates unique identifiers for different questions' do
    # Render first matching question
    render partial: "question/matchings/matching", locals: { matching: }
    first_rendered = rendered

    # Extract response identifiers from first rendering
    first_response_ids = first_rendered.scan(/response_lid ident="(response_\d+)"/).flatten

    # Render second matching question
    render partial: "question/matchings/matching", locals: { matching: another_matching }
    second_rendered = rendered

    # Extract response identifiers from second rendering
    second_response_ids = second_rendered.scan(/response_lid ident="(response_\d+)"/).flatten

    # Verify both questions have response identifiers
    expect(first_response_ids).not_to be_empty
    expect(second_response_ids).not_to be_empty

    # Verify the identifiers are different between questions
    expect(first_response_ids).not_to match_array(second_response_ids)
  end
end
