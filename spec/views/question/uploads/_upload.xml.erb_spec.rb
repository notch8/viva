# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'question/uploads/_upload' do
  let(:upload) { FactoryBot.build(:question_upload) }

  it 'renders xml' do
    render partial: "question/uploads/upload", locals: { upload: }
    expect(rendered).to include(%(<item ident="#{upload.item_ident}" title="Question #{upload.id}" >))

    # Yes the format type is essay question; perhaps there's a nuance that means Upload and Essay
    # are not identical; but this is what was requested so I'm assuming there's differences
    # somewhere.
    expect(rendered).to include(%(<fieldentry>file_upload_question</fieldentry>))

    # We are providing HTML and want to ensure it is escaped
    expect(rendered).to include(%(<mattext texttype="text/html">&lt;))
  end
end
