# frozen_string_literal: true

##
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)
require 'zip'

abort "Don't run this in production" if Rails.env.production?

if ENV['DEFAULT_USER_EMAIL'] && ENV['DEFAULT_USER_PASSWORD']
  u = User.find_or_create_by(email: ENV['DEFAULT_USER_EMAIL']) do |u|
    u.password = ENV['DEFAULT_USER_PASSWORD']
    u.admin = true
    u.active = true
  end
  # Update existing user if it already exists
  u.update(admin: true, active: true) if u.persisted?
end

u = User.find_or_create_by(email: ENV['INSTRUCTOR_USER_EMAIL1']) do |u|
  u.password = ENV['DEFAULT_USER_PASSWORD']
  u.active = true
end
# Update existing user if it already exists
u.update(active: true) if u.persisted?

u = User.find_or_create_by(email: ENV['INSTRUCTOR_USER_EMAIL2']) do |u|
  u.password = ENV['DEFAULT_USER_PASSWORD']
  u.active = true
end
# Update existing user if it already exists
u.update(active: true) if u.persisted?

user_id1 = User.find_by(email: ENV['INSTRUCTOR_USER_EMAIL1']).id
user_id2 = User.find_by(email: ENV['INSTRUCTOR_USER_EMAIL2']).id

# This is some very random data to quickly populate a non-production instance.
Subject.destroy_all

Question.find_each do |question|
  question.images.find_each do |image|
    image.file.purge if image.file.attached?
  end
end
Question.destroy_all

# require File.expand_path('../../spec/support/factory_bot', __FILE__)

# keywords = (1..10).map do |i|
#   FactoryBot.create(:keyword)
# end

# subjects = (1..10).map do |i|
#   FactoryBot.create(:subject)
# end

# Question.descendants.each do |qt|
#   (1..2).each do
#     question = FactoryBot.create(qt.model_name.param_key)
#     question.keywords = keywords.shuffle[0..rand(4)]
#     question.subjects = subjects.shuffle[0..rand(2)]
#     question.save!
#   end
# end

def zip_files(output_path, *files)
  Zip::File.open(output_path, Zip::File::CREATE) do |zipfile|
    files.each do |file_path|
      zipfile.add(File.basename(file_path), file_path)
    end
  end

  yield File.open(output_path) if block_given?
ensure
  File.delete(output_path) if File.exist?(output_path)
end

SubjectImporter.import
subjects = Subject.all
questions = []

###### Upload Questions
upload_questions_csv = File.open(Rails.root.join("db", "seed_csvs", "upload_questions.csv"))
questions << Question::ImporterCsv.from_file(upload_questions_csv, user_id: user_id1)

###### Multiple Choice Questions
csv_path = Rails.root.join("db", "seed_csvs", "multiple_choice_questions.csv")
image_path = Rails.root.join("db", "seed_images", "cat-injured.jpg")
zip_path = Rails.root.join("tmp", "multiple_choice_questions.zip")

zip_files(zip_path, csv_path, image_path) do |zip_file|
  questions << Question::ImporterCsv.from_file(zip_file, user_id: user_id2)
end

###### Select all that apply Questions
csv_path = Rails.root.join("db", "seed_csvs", "sata_questions.csv")
image_path = Rails.root.join("db", "seed_images", "dog-injured.jpg")
zip_path = Rails.root.join("tmp", "sata_questions.zip")

zip_files(zip_path, csv_path, image_path) do |zip_file|
  questions << Question::ImporterCsv.from_file(zip_file, user_id: user_id2)
end

#### Matching Questions
matching_questions_csv = File.open(Rails.root.join("db", "seed_csvs", "matching_questions.csv"))
questions << Question::ImporterCsv.from_file(matching_questions_csv, user_id: user_id1)

###### Essay Questions
essay_questions_csv = File.open(Rails.root.join("db", "seed_csvs", "essay_questions.csv"))
questions << Question::ImporterCsv.from_file(essay_questions_csv, user_id: user_id2)

###### Drag and Drop Questions
csv_path = Rails.root.join("db", "seed_csvs", "drag_and_drop_questions.csv")
image_path = Rails.root.join("db", "seed_images", "brain.jpg")
zip_path = Rails.root.join("tmp", "drag_and_drop_questions.zip")

zip_files(zip_path, csv_path, image_path) do |zip_file|
  questions << Question::ImporterCsv.from_file(zip_file, user_id: user_id2)
end

###### Categorization Questions
categorization_questions_csv = File.open(Rails.root.join("db", "seed_csvs", "categorization_questions.csv"))
questions << Question::ImporterCsv.from_file(categorization_questions_csv, user_id: user_id2)

bow_tie_question_1_data = {
  center: {
    label: "Patient Condition",
    answers: [
      {
        answer: "Diabetic Ketoacidosis",
        correct: true
      },
      {
        answer: "Hyperosmolar Hyperglycemic State",
        correct: false
      },
      {
        answer: "Hypoglycemia",
        correct: false
      },
      {
        answer: "Lactic Acidosis",
        correct: false
      }
    ]
  },
  left: {
    label: "Assessment Findings",
    answers: [
      {
        answer: "Blood glucose >250 mg/dL",
        correct: true
      },
      {
        answer: "Fruity breath odor (acetone)",
        correct: true
      },
      {
        answer: "Kussmaul respirations",
        correct: true
      },
      {
        answer: "Anion gap metabolic acidosis",
        correct: true
      },
      {
        answer: "Extreme thirst and polyuria",
        correct: true
      },
      {
        answer: "Blood glucose <70 mg/dL",
        correct: false
      },
      {
        answer: "Warm, flushed skin",
        correct: false
      }
    ]
  },
  right: {
    label: "Nursing Interventions",
    answers: [
      {
        answer: "Administer IV fluids as ordered",
        correct: true
      },
      {
        answer: "Monitor serum electrolytes",
        correct: true
      },
      {
        answer: "Administer insulin as prescribed",
        correct: true
      },
      {
        answer: "Monitor vital signs every 1-2 hours",
        correct: true
      },
      {
        answer: "Administer oral glucose gel",
        correct: false
      },
      {
        answer: "Restrict fluid intake",
        correct: false
      },
      {
        answer: "Apply cooling measures",
        correct: false
      }
    ]
  }
}

bow_tie_question_1 = Question::BowTie.new(
  text: "For the given patient condition, identify the corresponding assessment findings and appropriate nursing interventions.",
  data: bow_tie_question_1_data,
  user_id: user_id1
)
bow_tie_question_1.subjects << subjects.sample(rand(1..3))
questions << bow_tie_question_1

bow_tie_question_2_data = {
  center: {
    label: "Patient Condition",
    answers: [
      {
        answer: "Pulmonary Embolism",
        correct: true
      },
      {
        answer: "Myocardial Infarction",
        correct: false
      },
      {
        answer: "Pneumonia",
        correct: false
      },
      {
        answer: "Congestive Heart Failure",
        correct: false
      }
    ]
  },
  left: {
    label: "Assessment Findings",
    answers: [
      {
        answer: "Sudden onset dyspnea",
        correct: true
      },
      {
        answer: "Tachycardia",
        correct: true
      },
      {
        answer: "Pleuritic chest pain",
        correct: true
      },
      {
        answer: "Hypoxemia despite oxygen therapy",
        correct: true
      },
      {
        answer: "Risk factors: recent surgery, immobility, hormone therapy",
        correct: true
      },
      {
        answer: "Productive cough with purulent sputum",
        correct: false
      },
      {
        answer: "Gradual onset of symptoms over several days",
        correct: false
      }
    ]
  },
  right: {
    label: "Nursing Interventions",
    answers: [
      {
        answer: "Administer anticoagulant therapy as prescribed",
        correct: true
      },
      {
        answer: "Maintain oxygen therapy to keep SpO2 >92%",
        correct: true
      },
      {
        answer: "Position patient in semi-Fowler's or high Fowler's position",
        correct: true
      },
      {
        answer: "Monitor vital signs and respiratory status frequently",
        correct: true
      },
      {
        answer: "Administer IV thrombolytics as prescribed for massive PE",
        correct: true
      },
      {
        answer: "Encourage ambulation to improve circulation",
        correct: false
      },
      {
        answer: "Administer antibiotics as prescribed",
        correct: false
      }
    ]
  }
}

bow_tie_question_2 = Question::BowTie.new(
  text: "For the given patient condition, identify the correct assessment findings and appropriate nursing interventions.",
  data: bow_tie_question_2_data,
  user_id: user_id2
)
bow_tie_question_2.subjects << subjects.sample(rand(1..3))
questions << bow_tie_question_2

# First Stimulus Case Study - Respiratory Distress Case
stimulus_case_study_question_1 = Question::StimulusCaseStudy.new(
  text: "Respiratory Distress in a Geriatric Patient",
  user_id: user_id1
)
stimulus_case_study_question_1.subjects << subjects.sample(rand(1..3))

# Create a scenario as the first child
stimulus_case_study_1_scenario = Question::Scenario.new(
  text: "Mr. Henderson, a 78-year-old male, presents to the emergency department with complaints of progressive shortness of breath over the past 3 days. He reports a productive cough with yellow-green sputum and a fever of 101.2°F (38.4°C) at home this morning. His medical history includes COPD, hypertension, and type 2 diabetes. He uses supplemental oxygen at home (2L/min via nasal cannula). On assessment, vital signs are: BP 148/92 mmHg, HR 110 bpm, RR 28/min, SpO2 88% on room air, and temperature 38.6°C. Lung auscultation reveals diminished breath sounds in the right lower lobe with crackles and wheezing.",
  parent_question: stimulus_case_study_question_1,
  user_id: user_id1
)
stimulus_case_study_question_1.as_parent_question_aggregations.build(presentation_order: 0, child_question: stimulus_case_study_1_scenario)

# Add a traditional question
stimulus_case_study_traditional_1 = Question::Traditional.new(
  text: "Based on Mr. Henderson's presentation, what is the most likely diagnosis?",
  data: [
    { "answer" => "Community-acquired pneumonia", "correct" => true },
    { "answer" => "Pulmonary embolism", "correct" => false },
    { "answer" => "Acute exacerbation of COPD", "correct" => false },
    { "answer" => "Congestive heart failure", "correct" => false }
  ],
  child_of_aggregation: true,
  user_id: user_id1
)
stimulus_case_study_question_1.as_parent_question_aggregations.build(presentation_order: 1, child_question: stimulus_case_study_traditional_1)

# Add a select all that apply question with an image
stimulus_case_study_select_all_1 = Question::SelectAllThatApply.new(
  text: "Review the chest X-ray image. Which findings would you expect to observe in Mr. Henderson's radiograph? Select all that apply.",
  data: [
    { "answer" => "Right lower lobe infiltrate", "correct" => true },
    { "answer" => "Pleural effusion", "correct" => true },
    { "answer" => "Hyperinflation of lungs", "correct" => true },
    { "answer" => "Pneumothorax", "correct" => false },
    { "answer" => "Normal findings", "correct" => false }
  ],
  child_of_aggregation: true,
  user_id: user_id1
)

image = stimulus_case_study_select_all_1.images.build(alt_text: "Chest X-ray showing right lower lobe infiltrate and pleural effusion")
image.file.attach(io: File.open("db/seed_images/chest-xray.jpg"), filename: "chest-xray.jpg", content_type: "image/jpeg")

stimulus_case_study_question_1.as_parent_question_aggregations.build(presentation_order: 2, child_question: stimulus_case_study_select_all_1)

# Add another scenario
stimulus_case_study_1_scenario_2 = Question::Scenario.new(
  text: "After initial assessment, Mr. Henderson is diagnosed with community-acquired pneumonia with acute hypoxemic respiratory failure. The physician has ordered oxygen therapy, IV antibiotics, and chest physiotherapy.",
  parent_question: stimulus_case_study_question_1,
  user_id: user_id1
)
stimulus_case_study_question_1.as_parent_question_aggregations.build(presentation_order: 3, child_question: stimulus_case_study_1_scenario_2)

# Add a drag and drop question
stimulus_case_study_drag_drop_1 = Question::DragAndDrop.new(
  text: "Drag the appropriate interventions to complete the initial nursing care plan for Mr. Henderson:",
  data: [
    { "answer" => "Administer oxygen therapy to maintain SpO2 >92%", "correct" => true },
    { "answer" => "Monitor vital signs every 2-4 hours", "correct" => true },
    { "answer" => "Administer IV antibiotics as prescribed", "correct" => true },
    { "answer" => "Position patient in high Fowler's position to ease breathing", "correct" => true },
    { "answer" => "Encourage deep breathing and incentive spirometry", "correct" => true },
    { "answer" => "Restrict fluid intake to prevent pulmonary edema", "correct" => false },
    { "answer" => "Administer bronchodilators as needed", "correct" => false }
  ],
  child_of_aggregation: true,
  user_id: user_id1
)
stimulus_case_study_question_1.as_parent_question_aggregations.build(presentation_order: 4, child_question: stimulus_case_study_drag_drop_1)

# Add a matching question
stimulus_case_study_matching = Question::Matching.new(
  text: "Match each medication with its appropriate nursing consideration for Mr. Henderson's care:",
  data: [
    {
      "answer" => "Ceftriaxone (antibiotic)",
      "correct" => ["Monitor for signs of allergic reaction"]
    },
    {
      "answer" => "Albuterol (bronchodilator)",
      "correct" => ["Monitor for tachycardia and tremors"]
    },
    {
      "answer" => "Methylprednisolone (corticosteroid)",
      "correct" => ["Monitor blood glucose levels"]
    },
    {
      "answer" => "Enoxaparin (anticoagulant)",
      "correct" => ["Monitor for signs of bleeding"]
    }
  ],
  child_of_aggregation: true,
  user_id: user_id1
)
stimulus_case_study_question_1.as_parent_question_aggregations.build(presentation_order: 5, child_question: stimulus_case_study_matching)

questions << stimulus_case_study_question_1

# Second Stimulus Case Study - Neurological Assessment Case
stimulus_case_study_2 = Question::StimulusCaseStudy.new(
  text: "Neurological Assessment Following Trauma",
  user_id: user_id2
)
stimulus_case_study_2.subjects << subjects.sample(rand(1..3))

# Create a scenario as the first child
stimulus_case_study_2_scenario = Question::Scenario.new(
  text: "Emily Chen, a 24-year-old female, is brought to the emergency department by ambulance following a motor vehicle collision. She was the restrained driver and airbags deployed. On arrival, she is conscious but confused about the events. Initial assessment reveals a large contusion on her forehead, unequal pupils (right 5mm, left 3mm), and weakness in her left arm and leg. Vital signs: BP 160/95 mmHg, HR 100 bpm, RR 22/min, SpO2 97% on room air, GCS 13 (E3, V4, M6).",
  parent_question: stimulus_case_study_2,
  user_id: user_id2
)
stimulus_case_study_2.as_parent_question_aggregations.build(presentation_order: 0, child_question: stimulus_case_study_2_scenario)

# Add a bow tie question
stimulus_case_study_2_bow_tie = Question::BowTie.new(
  text: "Based on Emily's presentation, identify the clinical condition, assessment findings, and appropriate nursing interventions:",
  data: {
    center: {
      label: "Clinical Condition",
      answers: [
        {
          answer: "Traumatic Brain Injury",
          correct: true
        },
        {
          answer: "Stroke",
          correct: false
        },
        {
          answer: "Seizure Disorder",
          correct: false
        },
        {
          answer: "Meningitis",
          correct: false
        }
      ]
    },
    left: {
      label: "Assessment Findings",
      answers: [
        {
          answer: "Unequal pupils",
          correct: true
        },
        {
          answer: "Hemiparesis",
          correct: true
        },
        {
          answer: "Altered level of consciousness",
          correct: true
        },
        {
          answer: "Hypertension",
          correct: true
        },
        {
          answer: "History of trauma",
          correct: true
        },
        {
          answer: "Fever",
          correct: false
        },
        {
          answer: "Nuchal rigidity",
          correct: false
        }
      ]
    },
    right: {
      label: "Nursing Interventions",
      answers: [
        {
          answer: "Frequent neurological assessments",
          correct: true
        },
        {
          answer: "Maintain cervical spine precautions",
          correct: true
        },
        {
          answer: "Elevate head of bed 30 degrees",
          correct: true
        },
        {
          answer: "Monitor for increased intracranial pressure",
          correct: true
        },
        {
          answer: "Administer anticonvulsants prophylactically",
          correct: false
        },
        {
          answer: "Apply cooling measures",
          correct: false
        }
      ]
    }
  },
  child_of_aggregation: true,
  user_id: user_id2
)
stimulus_case_study_2.as_parent_question_aggregations.build(presentation_order: 1, child_question: stimulus_case_study_2_bow_tie)

# Add another scenario
stimulus_scenario_2 = Question::Scenario.new(
  text: "A CT scan is performed, revealing a small subdural hematoma with minimal midline shift. Emily is admitted to the ICU for close monitoring. Six hours after admission, the nurse notes that Emily's level of consciousness has decreased, with a GCS now at 10 (E2, V3, M5). Her right pupil is now 6mm and minimally reactive to light.",
  parent_question: stimulus_case_study_2,
  user_id: user_id2
)
stimulus_case_study_2.as_parent_question_aggregations.build(presentation_order: 2, child_question: stimulus_scenario_2)

# Add a traditional question with an image
stimulus_case_study_2_traditional = Question::Traditional.new(
  text: "Based on the CT scan image and Emily's deteriorating condition, what is the most likely cause of her declining neurological status?",
  data: [
    { "answer" => "Expanding intracranial hemorrhage", "correct" => true },
    { "answer" => "Cerebral edema", "correct" => false },
    { "answer" => "Seizure activity", "correct" => false },
    { "answer" => "Medication side effect", "correct" => false }
  ],
  child_of_aggregation: true,
  user_id: user_id2
)

image = stimulus_case_study_2_traditional.images.build(alt_text: "CT scan showing subdural hematoma with increasing midline shift")
image.file.attach(io: File.open("db/seed_images/brain-ct.jpg"), filename: "brain-ct.jpg", content_type: "image/jpeg")

stimulus_case_study_2.as_parent_question_aggregations.build(presentation_order: 3, child_question: stimulus_case_study_2_traditional)

# Add a categorization question
stimulus_case_study_2_categorization = Question::Categorization.new(
  text: "Categorize each assessment finding based on whether it indicates increased intracranial pressure or not:",
  data: [
    {
      "answer" => "Signs of Increased Intracranial Pressure",
      "correct" => ["Decreasing level of consciousness", "Pupillary changes (dilated, fixed)", "Cushing's triad (hypertension, bradycardia, irregular respirations)", "Projectile vomiting"]
    },
    {
      "answer" => "Not Specific to Increased Intracranial Pressure",
      "correct" => ["Fever", "Tachycardia", "Hypotension", "Hypoactive bowel sounds"]
    }
  ],
  child_of_aggregation: true,
  user_id: user_id2
)
stimulus_case_study_2.as_parent_question_aggregations.build(presentation_order: 4, child_question: stimulus_case_study_2_categorization)

# Add an essay question
stimulus_case_study_2_essay = Question::Essay.new(
  text: "Develop a comprehensive nursing care plan for Emily's first 24 hours in the ICU",
  data: {
    "html" => <<~HTML
      <div class="question-introduction">
        <p>Emily's condition requires specialized neurological nursing care to monitor for complications and prevent secondary brain injury. Your nursing care plan should address both her immediate neurological concerns and other potential complications associated with traumatic brain injury and immobility.</p>
      </div>

      <div class="question-prompt">
        <p><strong>Develop a comprehensive nursing care plan for Emily that includes:</strong></p>
        <ul>
          <li>At least three priority nursing diagnoses</li>
          <li>Specific interventions for neurological monitoring</li>
          <li>Measures to prevent increased intracranial pressure</li>
          <li>Interventions to prevent complications of immobility</li>
          <li>Family education components</li>
          <li>Expected outcomes for the first 24 hours</li>
        </ul>

        <p>Support your care plan with evidence-based rationales for each intervention.</p>
      </div>
    HTML
  },
  child_of_aggregation: true,
  user_id: user_id2
)
stimulus_case_study_2.as_parent_question_aggregations.build(presentation_order: 5, child_question: stimulus_case_study_2_essay)

questions << stimulus_case_study_2

questions.shuffle.each(&:save)

# Cleanup at the end
FileUtils.rm_rf(Rails.root.join("tmp", "unzipped"))
Dir.glob(Rails.root.join("tmp", "*.zip")).each { |f| File.delete(f) }
