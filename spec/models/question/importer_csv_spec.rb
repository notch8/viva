# frozen_string_literal: true

require 'rails_helper'
require 'zip'

RSpec.describe Question::ImporterCsv do
  let(:user) { create(:user) }
  subject(:instance) { described_class.new(text, user_id: user.id) }
  let!(:setting_names_array) do
    subjects_data = YAML.load_file('spec/fixtures/files/valid_subjects.yaml')
    subjects_data['subjects']['name']
  end

  before do
    allow(Subject).to receive(:names).and_return(setting_names_array)
  end

  describe '.from_file' do
    Rails.root.glob("spec/fixtures/files/valid_*.csv").each do |path|
      context "with \"#{File.basename(path)}\" when saved" do
        subject { described_class.from_file(file_fixture(File.basename(path)), user_id: user.id) }

        it 'creates at least one question' do
          # Also this is a great place to put a debug to see the output.
          expect { subject.save }.to change(Question, :count)
        end
      end
    end

    Rails.root.glob("spec/fixtures/files/invalid_*.csv").each do |path|
      context "with \"#{File.basename(path)}\" when saved" do
        subject { described_class.from_file(file_fixture(File.basename(path)), user_id: user.id) }

        it 'creates no questions' do
          # Also this is a great place to put a debug to see the output.
          expect do
            expect(subject.save).to be_falsey
          end.not_to change(Question, :count)

          subject.errors[:rows].each do |errors|
            expect(errors).to have_key(:import_id)
            expect(errors).to have_key(:base) # Probably
          end
        end
      end
    end

    Rails.root.glob("spec/fixtures/files/malformed_*.csv").each do |path|
      context "with \"#{File.basename(path)}\" when saved" do
        subject { described_class.from_file(file_fixture(File.basename(path)), user_id: user.id) }

        it 'creates no questions and indicates the message' do
          # Also this is a great place to put a debug to see the output.
          expect do
            expect(subject.save).to be_falsey
          end.not_to change(Question, :count)

          expect(subject.errors[:csv]).not_to be_empty
          expect(subject.errors[:csv].keys).to match_array([:message])
        end
      end
    end
  end

  context 'with type that does not have parts other rows say they are part of that type' do
    let(:text) do
      "IMPORT_ID,TYPE,TEXT,PART_OF,CORRECT_ANSWERS,ANSWER_1\n" \
      "1,Multiple Choice,Valid traditional,,1,You are correct sir!\n" \
      "2,Scenario,Valid scenario,1,\n"
    end

    it 'is not valid' do
      expect do
        expect(subject.save).to be_falsey
      end.not_to change(Question, :count)

      # Verifying the error message
      expect(subject.errors.dig(:rows, 0, :base, 0)).to include(Question.type_names_that_have_parts.join(', '))
    end
  end

  context 'with stimulus case study and child scenario' do
    let(:text) do
      "IMPORT_ID,TYPE,TEXT,PART_OF,CORRECT_ANSWERS,ANSWER_1,CENTER_LABEL,CENTER_1,CENTER_CORRECT_ANSWERS,LEFT_LABEL,LEFT_1,LEFT_CORRECT_ANSWERS,RIGHT_LABEL,RIGHT_1,RIGHT_CORRECT_ANSWERS\n" \
      "1,Stimulus Case Study,Valid study,,\n" \
      "2,Scenario,Valid scenario,1,\n" \
      "3,Multiple Choice,Valid traditional,1,1,You are correct sir!\n" \
      "4,Select All That Apply,Valid SATA,1,1,You are correct sir!\n" \
      "5,Bow Tie,Valid Bow Tie,1,,,CL,CA,1,LL,LA,1,RL,RA,1\n" \
      "6,Matching,Valid Matching,1,,,,,1,,LA,1,,RA,1\n"
    end

    it 'creates a case study and child scenario' do
      part_ofs = [
        Question::Scenario,
        Question::Traditional,
        Question::SelectAllThatApply,
        Question::BowTie,
        Question::Matching
      ]

      expect { subject.save }.to change(Question, :count).by(1 + part_ofs.size)

      scs = Question::StimulusCaseStudy.last

      children = part_ofs.each_with_object([]) do |part_of, array|
        child = part_of.last
        expect(child.parent_question).to eq(scs)
        array << child
      end

      expect(scs.child_questions).to match_array(children)
    end
  end

  context 'with duplicate IMPORT_ID' do
    let(:text) do
      "IMPORT_ID,TYPE,TEXT,CORRECT_ANSWERS,ANSWER_1,ANSWER_2,ANSWER_3\n" \
      "1,Multiple Choice,Which one is true?,1,true,false,Orc\n" \
      "1,Multiple Choice,Creature of Middle Earth?,3,true,false,Orc\n"
    end

    it 'does not persist the records and report errors' do
      expect { subject.save }.not_to change(Question::Traditional, :count)
      expect(subject.errors).to eq({ rows: [{ data: ["duplicate IMPORT_ID 1 found on multiple rows"], import_id: "1" }] })
    end
  end

  context 'with valid data' do
    let(:text) do
      "IMPORT_ID,TYPE,TEXT,CORRECT_ANSWERS,ANSWER_1,ANSWER_2,ANSWER_3\n" \
      "1,Multiple Choice,Which one is true?,1,true,false,Orc\n"
    end

    it 'persists the given records' do
      expect { subject.save }.to change(Question::Traditional, :count).by(1)
      expect(subject.errors).to be_empty
      json = subject.as_json
      expect(json.keys.sort).to eq([:errors, :questions])
      expect(json[:errors]).not_to be_present
      expect(json[:questions]).to be_present
    end
  end

  context 'with mixed valid data' do
    let(:text) do
      "IMPORT_ID,TYPE,,TEXT,CORRECT_ANSWERS,ANSWER_1,ANSWER_2,RIGHT_1,LEFT_1,ANSWER_3\n" \
      "1,Multiple Choice,,Which one is true?,1,true,false,,,Orc\n" \
      "2,Matching,,Pair Up,,,,Animal,Cat\n" \
      "3,Select All That Apply,,Which one is affirmative?,\"1,3\",true,false,,,yes\n" \
      "4,Drag and Drop,,What are Anmials?,\"1,2\",Cat,Dog,,,Shoe\n" \
      "5,Drag and Drop,,The ___1___ chases ___2___?,\"1,2\",Cat,Mouse,,,Umbrella\n"
    end

    it 'persists the given records' do
      expect do
        expect do
          expect do
            expect do
              subject.save
            end.to change(Question::Traditional, :count).by(1)
          end.to change(Question::Matching, :count).by(1)
        end.to change(Question::DragAndDrop, :count).by(2)
      end.to change(Question::SelectAllThatApply, :count).by(1)

      expect(subject.errors).to be_empty
    end
  end

  context 'with invalid data' do
    let(:text) do
      "IMPORT_ID,TYPE,TEXT,CORRECT_ANSWERS,ANSWER_1,ANSWER_2,ANSWER_3\n" \
      "1,Multiple Choice,I don't know?,4,a,b,c\n"
    end

    it 'does not persist the given records' do
      expect { subject.save }.not_to change(Question::Traditional, :count)
      expect(subject.errors).not_to be_empty

      expect(subject.errors[:rows]).to be_a(Array)

      json = subject.as_json
      expect(json.keys.sort).to eq([:errors, :questions])
      expect(json[:errors]['rows'].first.keys).to match_array(["base", "import_id"])
      expect(json[:questions]).not_to be_present
    end
  end

  context 'without an IMPORT_ID column' do
    let(:text) do
      "TYPE,TEXT,CORRECT_ANSWERS,ANSWER_1,ANSWER_2,ANSWER_3\n" \
      "Multiple Choice,I don't know?,1,a,b,c\n"
    end

    it 'does not persist the given records' do
      expect { subject.save }.not_to change(Question, :count)
      expect(subject.errors[:csv]).not_to be_empty
      expect(subject.errors[:csv].keys).to match_array([:expected, :given, :missing])

      json = subject.as_json
      expect(json.keys.sort).to eq([:errors, :questions])
      expect(json[:errors]['csv'].keys).to match_array(["expected", "given", "missing"])
      expect(json[:questions]).to be_present
    end
  end

  context 'with a zip file' do
    subject { described_class.from_file(file_fixture(zip_file_with_one_question_with_two_images), user_id: user.id) }

    let(:zip_file_with_one_question_with_two_images) { 'test.zip' }

    it 'attaches the image to the question' do
      expect { subject.save }.to change(Image, :count).by(2).and change(Question, :count).by(1)

      question = subject.instance_variable_get(:@questions)["1"].question
      expect(question.images.first.file.filename).to eq('test_image.jpg')
      expect(question.images.first.alt_text).to eq('Test JPG')
      expect(question.images.last.file.filename).to eq('test_image.png')
      expect(question.images.last.alt_text).to eq('Test PNG')
    end
  end

  context 'with CSV containing IMAGE_PATH but no ZIP file' do
    let(:text) do
      "IMPORT_ID,TYPE,TEXT,IMAGE_PATH,CORRECT_ANSWERS,ANSWER_1,ANSWER_2\n" \
      "1,Multiple Choice,Which one is true?,image.jpg,1,true,false\n"
    end

    it 'adds an error and does not persist the question' do
      expect { subject.save }.not_to change(Question, :count)
      expect(subject.errors[:rows]).to be_present
      error_message = subject.errors[:rows].first[:base].first
      expect(error_message).to include('Images specified in CSV but no ZIP file uploaded')
    end
  end

  context 'with ZIP file but missing image' do
    let(:temp_dir) { Dir.mktmpdir }
    let(:csv_content) do
      "IMPORT_ID,TYPE,TEXT,IMAGE_PATH,CORRECT_ANSWERS,ANSWER_1,ANSWER_2\n" \
      "1,Multiple Choice,Which one is true?,missing_image.jpg,1,true,false\n"
    end
    let(:zip_path) { File.join(temp_dir, 'test.zip') }
    let(:csv_path) { File.join(temp_dir, 'test.csv') }

    before do
      File.write(csv_path, csv_content)
      Zip::File.open(zip_path, Zip::File::CREATE) do |zip|
        zip.add('test.csv', csv_path)
        # Intentionally not adding the image file
      end
    end

    after do
      FileUtils.rm_rf(temp_dir)
    end

    it 'adds an error with available files listed' do
      importer = described_class.from_file(File.open(zip_path), user_id: user.id)
      expect { importer.save }.not_to change(Question, :count)
      expect(importer.errors[:rows]).to be_present
      error_message = importer.errors[:rows].first[:base].first
      expect(error_message).to include('Image file not found in ZIP: missing_image.jpg')
      expect(error_message).to include('Available files:')
    end
  end

  context 'with ZIP file and image path with whitespace' do
    let(:temp_dir) { Dir.mktmpdir }
    let(:csv_content) do
      "IMPORT_ID,TYPE,TEXT,IMAGE_PATH,CORRECT_ANSWERS,ANSWER_1,ANSWER_2\n" \
      "1,Multiple Choice,Which one is true?,\" image.jpg ; image2.png \",1,true,false\n"
    end
    let(:zip_path) { File.join(temp_dir, 'test.zip') }
    let(:csv_path) { File.join(temp_dir, 'test.csv') }
    let(:image_path) { File.join(temp_dir, 'image.jpg') }
    let(:image2_path) { File.join(temp_dir, 'image2.png') }

    before do
      File.write(csv_path, csv_content)
      # Create dummy image files
      File.write(image_path, 'fake image data')
      File.write(image2_path, 'fake image data 2')
      Zip::File.open(zip_path, Zip::File::CREATE) do |zip|
        zip.add('test.csv', csv_path)
        zip.add('image.jpg', image_path)
        zip.add('image2.png', image2_path)
      end
    end

    after do
      FileUtils.rm_rf(temp_dir)
    end

    it 'strips whitespace and attaches images correctly' do
      importer = described_class.from_file(File.open(zip_path), user_id: user.id)
      expect { importer.save }.to change(Image, :count).by(2).and change(Question, :count).by(1)
      question = importer.instance_variable_get(:@questions)["1"].question
      expect(question.images.count).to eq(2)
      expect(question.images.map(&:file).map(&:filename).map(&:to_s)).to contain_exactly('image.jpg', 'image2.png')
    end
  end

  context 'with ZIP file and image in subdirectory' do
    let(:temp_dir) { Dir.mktmpdir }
    let(:csv_content) do
      "IMPORT_ID,TYPE,TEXT,IMAGE_PATH,CORRECT_ANSWERS,ANSWER_1,ANSWER_2\n" \
      "1,Multiple Choice,Which one is true?,files/image.jpg,1,true,false\n"
    end
    let(:zip_path) { File.join(temp_dir, 'test.zip') }
    let(:csv_path) { File.join(temp_dir, 'test.csv') }
    let(:files_dir) { File.join(temp_dir, 'files') }
    let(:image_path) { File.join(files_dir, 'image.jpg') }

    before do
      FileUtils.mkdir_p(files_dir)
      File.write(csv_path, csv_content)
      File.write(image_path, 'fake image data')
      Zip::File.open(zip_path, Zip::File::CREATE) do |zip|
        zip.add('test.csv', csv_path)
        zip.add('files/image.jpg', image_path)
      end
    end

    after do
      FileUtils.rm_rf(temp_dir)
    end

    it 'finds and attaches image from subdirectory' do
      importer = described_class.from_file(File.open(zip_path), user_id: user.id)
      expect { importer.save }.to change(Image, :count).by(1).and change(Question, :count).by(1)
      question = importer.instance_variable_get(:@questions)["1"].question
      expect(question.images.first.file.filename).to eq('image.jpg')
    end
  end
end
