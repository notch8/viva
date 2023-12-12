# frozen_string_literal: true

RSpec.shared_examples 'a Question' do |valid: true, export_as_xml: false, test_type_name_to_class: true, included_in_filterable_type: true, has_parts: false|
  it { is_expected.to respond_to(:keyword_names) }
  it { is_expected.to respond_to(:subject_names) }
  its(:keyword_names) { is_expected.to be_a(Array) }
  its(:subject_names) { is_expected.to be_a(Array) }
  its(:type_label) { is_expected.to be_a(String) }
  its(:type_name) { is_expected.to be_a(String) }
  its(:included_in_filterable_type?) { is_expected.to eq(included_in_filterable_type) }
  its(:has_parts?) { is_expected.to eq(has_parts) }
  its(:question) { is_expected.to be_a(described_class) }
  its(:question) { is_expected.to eq(subject) }
  its(:qti_max_value) { is_expected.to eq(100) }

  if test_type_name_to_class
    describe '.type_name_to_class' do
      subject { described_class.type_name_to_class(described_class.type_name) }

      it { is_expected.to eq(described_class) }
    end
  end

  describe 'QTI Export' do
    its(:assessment_question_identifierref) { is_expected.to be_a(String) }
    its(:export_as_xml) { is_expected.to eq(export_as_xml) }
  end

  describe 'validations' do
    subject { described_class.new }
    it { is_expected.to validate_presence_of(:text) }
    it { is_expected.to validate_presence_of(:type) }
  end

  describe '.build_row' do
    subject { described_class }
    it { is_expected.to respond_to(:build_row) }
  end

  describe 'associations' do
    subject { described_class.new }
    it { is_expected.to have_and_belong_to_many(:subjects) }
    it { is_expected.to have_and_belong_to_many(:keywords) }
    it { is_expected.to have_one(:as_child_question_aggregations) }
    it { is_expected.to have_one(:parent_question) }
  end

  describe 'factories' do
    subject { FactoryBot.build(described_class.model_name.param_key) }

    describe ":with_keywords trait" do
      context 'when provided' do
        subject { FactoryBot.build(described_class.model_name.param_key, :with_keywords) }

        its(:keywords) { is_expected.to be_present }
      end
      context 'when not provided' do
        its(:keywords) { is_expected.not_to be_present }
      end
    end
    describe ":with_subjects trait" do
      context 'when provided' do
        subject { FactoryBot.build(described_class.model_name.param_key, :with_subjects) }

        its(:subjects) { is_expected.to be_present }
      end
      context 'when not provided' do
        its(:keywords) { is_expected.not_to be_present }
      end
    end

    if valid
      it { is_expected.to be_valid }
    else
      it { is_expected.not_to be_valid }
    end
  end
end

RSpec.shared_examples 'a Matching Question' do
  describe '.build_row' do
    subject { described_class.build_row(row:, questions: {}) }
    context 'with invalid data due to mismatched columns' do
      let(:row) do
        CsvRow.new("TYPE" => described_class.type_name,
                   "TEXT" => "#{described_class.type_name} the proper pairings:",
                   "LEVEL" => Level.names.first,
                   "LEFT_1" => "Animal",
                   "LEFT_3" => "Mineral",
                   "RIGHT_2" => "Cat, Dog",
                   "RIGHT_4" => "Weird",
                   "LEFT_5" => "Yup",
                   "RIGHT_5" => "It Matches",
                   "KEYWORD" => "One, Two",
                   "SUBJECT" => "Big, Little")
      end
      it { is_expected.not_to be_valid }
      it { is_expected.not_to be_persisted }
      it "will not call the underlying question's save!" do
        expect(subject.question).not_to receive(:save!)
        # I could have one regular expression for this, but figure splitting it apart helps show with clarity.
        expect { subject.save! }.to raise_error(/Have LEFT_1, LEFT_3 columns without corresponding RIGHT_1, RIGHT_3 columns/)
        expect { subject.save! }.to raise_error(/Have RIGHT_2, RIGHT_4 columns without corresponding LEFT_2, LEFT_4 columns/)
      end
    end

    context 'with valid data' do
      let(:row) do
        CsvRow.new("TYPE" => described_class.type_name,
                   "TEXT" => "#{described_class.type_name} the proper pairings:",
                   "LEVEL" => Level.names.first,
                   "LEFT_1" => "Animal",
                   "RIGHT_1" => "Cat, Dog",
                   "LEFT_2" => "Plant",
                   "RIGHT_2" => "Catnip, Dogwood",
                   "LEFT_3" => "",
                   "RIGHT_3" => "",
                   "KEYWORD" => "One, Two",
                   "SUBJECT" => "Big, Little")
      end

      it { is_expected.to be_valid }
      it { is_expected.not_to be_persisted }
      its(:data) { is_expected.to eq([{ "answer" => "Animal", "correct" => ["Cat", "Dog"] }, { "answer" => "Plant", "correct" => ["Catnip", "Dogwood"] }]) }

      context 'when saved' do
        before { subject.save }

        its(:keyword_names) { is_expected.to match_array(["One", "Two"]) }
        its(:subject_names) { is_expected.to match_array(["Big", "Little"]) }
        its(:level) { is_expected.to eq(Level.names.first) }
      end
    end
  end

  describe 'data serialization' do
    subject { FactoryBot.build("question_#{described_class.name.demodulize.underscore}", data:) }
    [
      [[{ 'answer' => "Hello", 'correct' => ["World"] }, { 'answer' => "Wonder", 'correct' => ["Wall"] }], true],
      [[{ 'answer' => "Hello", 'correct' => ["World"] }, { 'answer' => "Wonder", 'correct' => ["Wall", "Bread"] }], true],
      [[{ 'answer' => "Hello", 'correct' => "World" }], false],
      [[{ 'answer' => "Hello", 'correct' => ["World"] }], true],
      # When missing the right side of a pairing
      [[{ 'answer' => "Hello" }, { 'answer' => "Wonder", 'correct' => ["Wall"] }], false],
      # When having an empty middle-part
      [[{ 'answer' => "Hello" }, [], { 'answer' => "Wonder", 'correct' => ["Wall"] }], false],
      [nil, false],
      [[], false],
      # Given an array that has a blank value.
      [[{ 'answer' => "Hello", 'correct' => [""] }, { 'answer' => "Wonder", 'correct' => ["Wall"] }], false],
      # Given an array an answer is an empty array
      [[{ 'answer' => "Hello", 'correct' => [] }, { 'answer' => "Wonder", 'correct' => ["Wall"] }], false]
    ].each do |given, valid|
      context "when given #{given.inspect}" do
        let(:data) { given }

        if valid
          it { is_expected.to be_valid }
        else
          it { is_expected.not_to be_valid }
        end
      end
    end
  end

  describe 'QTI Exporting' do
    let(:instance) { FactoryBot.build(:question_matching) }

    describe '#qti_choices' do
      it "is an Array of Choice objects" do
        expect(instance.qti_choices.all? { |r| r.is_a?(described_class::Choice) }).to be_truthy
      end
    end

    describe '#qti_response_conditions' do
      it "is an Array of ResponseCondition objects" do
        expect(instance.qti_response_conditions.all? { |r| r.is_a?(described_class::ResponseCondition) }).to be_truthy
      end
    end

    describe '#qti_responses' do
      it "is an Array of Response objects" do
        expect(instance.qti_responses.all? { |r| r.is_a?(described_class::Response) }).to be_truthy
      end
    end
  end
end

RSpec.shared_examples 'a Markdown Question' do
  describe '.build_row' do
    subject { described_class.build_row(row:, questions: {}) }
    context 'with invalid data due to mismatched columns' do
      let(:row) do
        CsvRow.new("TYPE" => described_class.type_name,
                   "KEYWORD" => "One, Two",
                   "SUBJECT" => "Big, Little")
      end
      it { is_expected.not_to be_valid }
      it { is_expected.not_to be_persisted }
      it "will not call the underlying question's save!" do
        expect(subject.question).not_to receive(:save!)
        expect { subject.save! }.to raise_error(/expected one or more TEXT columns/)
      end
    end

    context 'with at least one SECTION_ column' do
      let(:row) do
        CsvRow.new("TYPE" => described_class.type_name,
                   "TEXT" => "Title of Question",
                   "TEXT_1" => "* Bullet Point",
                   "TEXT_2" => "* Second Point",
                   "TEXT_3" => "<script>alert('Hello');</script>",
                   "KEYWORD" => "One, Two",
                   "SUBJECT" => "Big, Little")
      end

      it { is_expected.to be_valid }
      it { is_expected.not_to be_persisted }
      let(:expected_html) { "<p>Title of Question</p><ul><li><p>Bullet Point</p></li><li><p>Second Point</p></li></ul>" }
      its(:data) { is_expected.to eq({ "html" => expected_html }) }

      it 'will save the underlying record' do
        expect { subject.save }.to change(described_class, :count).by(1)
      end
    end
  end
end
