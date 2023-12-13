# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'question/essays/_essay' do
  let(:essay) { FactoryBot.build(:question_essay) }

  it 'renders xml' do
    render partial: "question/essays/essay", locals: { essay: }
    expect(rendered).to include(%(<item ident="#{essay.item_ident}" title="Question #{essay.id}" >))
    # This appears to be a hard-coded assumption
    expect(rendered).to include(%(<fieldentry>essay_question</fieldentry>))

    # We are providing HTML and want to ensure it is escaped
    expect(rendered).to include(%(<mattext texttype="text/html">&lt;))
  end
end
