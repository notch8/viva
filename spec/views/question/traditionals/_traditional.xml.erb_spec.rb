# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'question/traditionals/_traditional' do
  let(:traditional) { FactoryBot.build(:question_traditional) }

  it 'renders xml' do
    render partial: "question/traditionals/traditional", locals: { traditional: }
    expect(rendered).to include(%(<item ident="#{traditional.item_ident}" title="Question #{traditional.id}" >))
    # This appears to be a hard-coded assumption
    expect(rendered).to include(%(<fieldentry>multiple_choice_question</fieldentry>))
  end
end
