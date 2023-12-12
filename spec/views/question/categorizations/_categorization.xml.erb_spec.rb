# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'question/categorizations/_categorization' do
  let(:categorization) { FactoryBot.build(:question_categorization) }

  it 'renders xml' do
    render partial: "question/categorizations/categorization", locals: { categorization: }
    expect(rendered).to include(%(<item ident="#{categorization.item_ident}" title="Question #{categorization.id}" >))
    # Unlike Question::Matching; the matching requires multiple.
    expect(rendered).to include(%(rcardinality="Multiple">))
    expect(rendered).to include(%(<fieldentry>categorization_question</fieldentry>))
  end
end
