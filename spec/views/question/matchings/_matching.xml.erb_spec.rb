# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'question/matchings/_matching' do
  let(:matching) { FactoryBot.build(:question_matching) }

  it 'renders xml' do
    render partial: "question/matchings/matching", locals: { matching: }
    expect(rendered).to include(%(<item ident="#{matching.item_ident}" title="Question #{matching.id}" >))
    # Unlike Question::Categorization; the matching does not allow for multiple.
    # See https://github.com/notch8/viva/issues/237
    expect(rendered).not_to include(%(rcardinality="Multiple">))
    expect(rendered).to include(%(<fieldentry>matching_question</fieldentry>))
  end
end
