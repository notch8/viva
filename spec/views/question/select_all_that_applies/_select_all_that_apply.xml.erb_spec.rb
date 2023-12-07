# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'question/select_all_that_applies/_select_all_that_apply' do
  let(:select_all_that_apply) { FactoryBot.build(:question_select_all_that_apply) }

  it 'renders xml' do
    render partial: 'question/select_all_that_applies/select_all_that_apply', locals: { select_all_that_apply: }
    expect(rendered).to include(%(<item ident="#{select_all_that_apply.item_ident}" title="Question #{select_all_that_apply.id}" >))
  end
end
