# frozen_string_literal: true

##
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

abort "Don't run this in production" if Rails.env.production?

if ENV['DEFAULT_USER_EMAIL'] && ENV['DEFAULT_USER_PASSWORD']
  u = User.find_or_create_by(email: ENV['DEFAULT_USER_EMAIL']) do |u|
    u.password = ENV['DEFAULT_USER_PASSWORD']
  end
end


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

SubjectImporter.import
subjects = Subject.all
questions = []

upload_question_1_data = {
  "text" => "Develop a Comprehensive Heart Failure Nursing Care Plan",
  "html" => <<~HTML
    <div class="question-introduction">
      <h3>Understanding Nursing Care Plans for Patients with Heart Failure</h3>

      <p>Heart failure is a complex clinical syndrome that occurs when the heart is unable to pump sufficient blood to meet the body's metabolic demands. It affects approximately 6.2 million adults in the United States and is a leading cause of hospitalization among adults over the age of 65.</p>

      <p>Effective management of heart failure requires a comprehensive, multidisciplinary approach. Nursing care plans are essential tools that help organize assessments, interventions, and evaluations to address the specific needs of patients with heart failure.</p>

      <p>Key components of a nursing care plan for heart failure include:</p>
      <ul>
        <li>Assessment of cardiac function and symptoms (dyspnea, orthopnea, fatigue, edema)</li>
        <li>Monitoring of fluid status and weight</li>
        <li>Medication management (diuretics, ACE inhibitors, beta-blockers)</li>
        <li>Activity and exercise recommendations</li>
        <li>Dietary modifications (sodium and fluid restrictions)</li>
        <li>Patient education on self-management strategies</li>
        <li>Psychosocial support</li>
      </ul>
    </div>

    <div class="question-prompt">
      <h4>Assignment:</h4>
      <p>You are caring for Mr. James Thompson, a 72-year-old male admitted to the medical-surgical unit with acute decompensated heart failure (NYHA Class III). His medical history includes hypertension, type 2 diabetes, and a previous myocardial infarction 5 years ago.</p>

      <p>Current assessment findings include:</p>
      <ul>
        <li>Vital signs: BP 152/88 mmHg, HR 92 bpm, RR 24/min, O2 saturation 91% on room air</li>
        <li>Bilateral crackles in lung bases</li>
        <li>3+ pitting edema in lower extremities</li>
        <li>Weight gain of 4.5 kg over the past week</li>
        <li>Decreased appetite and increased fatigue</li>
        <li>Lab values: BNP 850 pg/mL, Na+ 133 mEq/L, K+ 3.8 mEq/L, BUN 32 mg/dL, Creatinine 1.4 mg/dL</li>
      </ul>

      <p><strong>Develop a comprehensive nursing care plan for Mr. Thompson that addresses his heart failure exacerbation. Your care plan should include at least three nursing diagnoses with corresponding goals, interventions, and evaluation criteria. Also include specific patient education elements that would be essential before discharge.</strong></p>

      <p>Please upload your nursing care plan as a document file. Your submission will be evaluated on its comprehensiveness, clinical reasoning, evidence-based interventions, and attention to holistic patient needs.</p>
    </div>
  HTML
}

upload_question_1 = Question::Upload.new(text: upload_question_1_data["text"], data: upload_question_1_data)
upload_question_1.subjects << subjects.sample(2)
questions << upload_question_1

upload_question_2_data = {
  "text" => "Develop a Pediatric Asthma Action Plan for School and Home",
  "html" => <<~HTML
    <div class="question-introduction">
      <h3>Pediatric Asthma Management and Education</h3>

      <p>Asthma is one of the most common chronic diseases of childhood, affecting approximately 6 million children under 18 years of age in the United States. Effective asthma management requires a coordinated approach between healthcare providers, families, schools, and the community.</p>

      <p>Pediatric asthma management presents unique challenges compared to adult care, including:</p>
      <ul>
        <li>Developmental considerations in symptom recognition and medication administration</li>
        <li>Need for family and caregiver education</li>
        <li>School and childcare coordination</li>
        <li>Age-appropriate education strategies</li>
        <li>Impact on growth, development, and quality of life</li>
        <li>Environmental trigger assessment in multiple settings</li>
      </ul>

      <p>The Asthma Action Plan is a critical tool that helps children, families, and other caregivers recognize worsening asthma symptoms and respond appropriately with medication adjustments and environmental modifications.</p>
    </div>

    <div class="question-prompt">
      <h4>Assignment:</h4>
      <p>You are caring for Emily Roberts, an 8-year-old female recently discharged from the hospital following her second asthma exacerbation this year. She has moderate persistent asthma and lives with her mother and younger brother in an apartment. Emily is entering third grade next month.</p>

      <p>Current clinical information:</p>
      <ul>
        <li>Prescribed medications: Fluticasone 88 mcg inhaler (2 puffs twice daily), Albuterol inhaler (2 puffs as needed for symptoms), oral prednisone taper following recent exacerbation</li>
        <li>Pulmonary function tests show FEV1 of 78% of predicted when stable</li>
        <li>Identified triggers include respiratory infections, exercise, pollen, and exposure to cigarette smoke (a neighbor smokes in the shared hallway)</li>
        <li>Emily's mother works full-time and reports difficulty remembering the controller medication routine</li>
        <li>Emily participates in soccer and swimming but has missed several practices due to asthma symptoms</li>
      </ul>

      <p><strong>Create a comprehensive pediatric asthma action plan for Emily that can be used both at home and school. Your plan should include:</strong></p>
      <ol>
        <li>Clear identification of green (well-controlled), yellow (caution), and red (emergency) zones with corresponding symptoms and actions</li>
        <li>Medication instructions with age-appropriate considerations</li>
        <li>Specific recommendations for school staff, including PE teachers</li>
        <li>Strategies to improve medication adherence</li>
        <li>Environmental control measures for both home and school</li>
        <li>Family education plan with developmentally appropriate teaching strategies for Emily</li>
      </ol>

      <p>Please upload your pediatric asthma action plan as a document file. Your submission should demonstrate understanding of pediatric asthma management principles, family-centered care, and interdisciplinary collaboration.</p>
    </div>
  HTML
}

upload_question_2 = Question::Upload.new(text: upload_question_2_data["text"], data: upload_question_2_data)
upload_question_2.subjects << subjects.sample(2)
questions << upload_question_2

traditional_question_data = [
  { "answer" => "Administer a prescribed diuretic and monitor fluid balance", "correct" => true },
  { "answer" => "Administer oxygen at 5L/min via nasal cannula regardless of oxygen saturation", "correct" => false },
  { "answer" => "Place the patient in a supine position to improve cardiac output", "correct" => false },
  { "answer" => "Discontinue all fluid intake until edema resolves", "correct" => false }
]

traditional_question_1 = Question::Traditional.new(
  text: "A nurse is caring for a patient admitted with acute heart failure. The patient has 3+ pitting edema in the lower extremities and crackles in the lung bases. What is the most appropriate initial nursing intervention?",
  data: traditional_question_data
)
traditional_question_1.subjects << subjects.sample(rand(1..3))
questions << traditional_question_1

traditional_question_data_2 = [
  { "answer" => "Document the findings and continue routine postpartum assessments", "correct" => false },
  { "answer" => "Notify the healthcare provider immediately for further evaluation", "correct" => true },
  { "answer" => "Administer PRN pain medication and reassess in 1 hour", "correct" => false },
  { "answer" => "Encourage the patient to ambulate to reduce uterine cramping", "correct" => false }
]

traditional_question_2 = Question::Traditional.new(
  text: "A postpartum nurse is assessing a patient who delivered vaginally 6 hours ago. The nurse notes the uterine fundus is boggy and 2 cm above the umbilicus, with moderate lochia rubra. The patient's vital signs are BP 100/60, HR 118, RR 20, and temp 37.2°C. What is the most appropriate nursing action?",
  data: traditional_question_data_2
)
traditional_question_2.subjects << subjects.sample(rand(1..3))
questions << traditional_question_2

traditional_question_data_3 = [
  { "answer" => "Stop the medication immediately and notify the physician", "correct" => true },
  { "answer" => "Continue administration at a slower rate and monitor vital signs", "correct" => false },
  { "answer" => "Administer diphenhydramine as prescribed and continue the infusion", "correct" => false },
  { "answer" => "Document the reaction and complete the scheduled dose", "correct" => false }
]

traditional_question_3 = Question::Traditional.new(
  text: "A nurse is administering IV vancomycin to a patient. Twenty minutes into the infusion, the patient develops a diffuse erythematous rash on the face, neck, and upper torso, accompanied by hypotension with BP 90/50 mmHg. What is the priority nursing action?",
  data: traditional_question_data_3
)
traditional_question_3.subjects << subjects.sample(rand(1..3))
questions << traditional_question_3

traditional_question_4_data = [
  { "answer" => "Stage 2 pressure injury", "correct" => false },
  { "answer" => "Stage 3 pressure injury", "correct" => true },
  { "answer" => "Stage 4 pressure injury", "correct" => false },
  { "answer" => "Unstageable pressure injury", "correct" => false }
]

traditional_question_4 = Question::Traditional.new(
  text: "Based on the image, which classification best describes this pressure injury?",
  data: traditional_question_4_data
)

image = traditional_question_4.images.build(alt_text: "Image of a pressure injury showing full-thickness skin loss with visible subcutaneous fat")
image.file.attach(io: File.open("db/seed_images/cat-injured.jpg"), filename: "cat-injured.jpg", content_type: "image/jpeg")
traditional_question_4.subjects << subjects.sample(rand(1..3))
questions << traditional_question_4

select_all_question_1_data = [
  { "answer" => "Monitor vital signs every 2-4 hours", "correct" => true },
  { "answer" => "Maintain head of bed elevation at 30-45 degrees", "correct" => true },
  { "answer" => "Administer antibiotics as prescribed on time", "correct" => true },
  { "answer" => "Restrict fluid intake to prevent pulmonary edema", "correct" => false },
  { "answer" => "Place the patient in a supine position for lung expansion", "correct" => false }
]

select_all_question_1 = Question::SelectAllThatApply.new(
  text: "A nurse is caring for a patient diagnosed with community-acquired pneumonia. Which nursing interventions are appropriate for this patient? Select all that apply.",
  data: select_all_question_1_data
)
select_all_question_1.subjects << subjects.sample(rand(1..3))
questions << select_all_question_1

select_all_question_2_data = [
  { "answer" => "Assess for urinary retention using a bladder scanner", "correct" => true },
  { "answer" => "Ensure the catheter is secured to prevent traction", "correct" => true },
  { "answer" => "Maintain the drainage bag below the level of the bladder", "correct" => true },
  { "answer" => "Cleanse the perineal area with antiseptic solution every 8 hours", "correct" => true },
  { "answer" => "Routinely irrigate the catheter every shift to maintain patency", "correct" => false }
]

select_all_question_2 = Question::SelectAllThatApply.new(
  text: "A nurse is implementing care for a patient with an indwelling urinary catheter. Which of the following interventions should be included in the care plan? Select all that apply.",
  data: select_all_question_2_data
)
select_all_question_2.subjects << subjects.sample(rand(1..3))
questions << select_all_question_2

matching_question_data = [
  { "key" => "Digoxin", "value" => "Monitor for bradycardia and dysrhythmias" },
  { "key" => "Furosemide", "value" => "Monitor for electrolyte imbalances and dehydration" },
  { "key" => "Warfarin", "value" => "Monitor for bleeding and check INR levels" },
  { "key" => "Metformin", "value" => "Monitor for lactic acidosis and check renal function" },
  { "key" => "Levothyroxine", "value" => "Monitor for signs of hyperthyroidism and check TSH levels" }
]

matching_question_data = [
  {
    "answer" => "Digoxin",
    "correct" => ["Monitor for bradycardia and dysrhythmias"]
  },
  {
    "answer" => "Furosemide",
    "correct" => ["Monitor for electrolyte imbalances and dehydration"]
  },
  {
    "answer" => "Warfarin",
    "correct" => ["Monitor for bleeding and check INR levels"]
  },
  {
    "answer" => "Metformin",
    "correct" => ["Monitor for lactic acidosis and check renal function"]
  },
  {
    "answer" => "Levothyroxine",
    "correct" => ["Monitor for signs of hyperthyroidism and check TSH levels"]
  }
]

matching_question_1 = Question::Matching.new(
  text: "Match each medication to its appropriate nursing consideration:",
  data: matching_question_data
)
matching_question_1.subjects << subjects.sample(rand(1..3))
questions << matching_question_1

matching_question_data_2 = [
  {
    "answer" => "Tachypnea",
    "correct" => ["Increased respiratory rate greater than 20 breaths per minute"]
  },
  {
    "answer" => "Bradycardia",
    "correct" => ["Heart rate less than 60 beats per minute"]
  },
  {
    "answer" => "Hypertension",
    "correct" => ["Blood pressure reading higher than 140/90 mmHg"]
  },
  {
    "answer" => "Pyrexia",
    "correct" => ["Elevated body temperature above 38°C (100.4°F)"]
  },
  {
    "answer" => "Oliguria",
    "correct" => ["Urine output less than 400 mL in 24 hours"]
  }
]

matching_question_2 = Question::Matching.new(
  text: "Match each vital sign abnormality with its clinical definition:",
  data: matching_question_data_2
)
matching_question_2.subjects << subjects.sample(rand(1..3))
questions << matching_question_2

essay_question_data = {
  "html" => <<~HTML
    <div class="question-introduction">
      <h3>Nursing Ethics in End-of-Life Care</h3>

      <p>End-of-life care presents numerous ethical challenges for nursing professionals. The principles of autonomy, beneficence, non-maleficence, and justice must be carefully balanced when caring for patients approaching the end of life. Nurses often serve as patient advocates, helping to ensure that patients' wishes regarding their care are respected.</p>

      <p>Advance directives, such as living wills and durable power of attorney for healthcare, play a critical role in guiding healthcare decisions when patients cannot communicate their wishes. However, situations may arise where family members disagree with documented wishes, or where the patient's current non-verbal cues seem to contradict previously stated preferences.</p>

      <p>In addition, nurses must navigate complex issues related to pain management, palliative sedation, withdrawal of life-sustaining treatments, and cultural or religious considerations that influence end-of-life care preferences.</p>
    </div>

    <div class="question-prompt">
      <p>You are caring for Mrs. Rodriguez, an 82-year-old patient with advanced dementia and newly diagnosed metastatic cancer. She has a clearly documented advance directive stating she does not want artificial nutrition, hydration, or resuscitation efforts. However, her daughter insists that "if mom knew she had cancer, she would want everything done" and demands aggressive treatment including a feeding tube.</p>

      <p><strong>Describe the ethical dilemma in this scenario and explain how you would approach this situation as the patient's nurse. Include in your discussion:</strong></p>
      <ul>
        <li>The key ethical principles involved</li>
        <li>Your role as patient advocate</li>
        <li>Strategies for communicating with the family</li>
        <li>Resources you would utilize (ethics committee, palliative care team, etc.)</li>
        <li>How you would document your nursing actions</li>
      </ul>

      <p>Support your response with specific references to the nursing code of ethics and current best practices in end-of-life care.</p>
    </div>
  HTML
}

essay_question_1 = Question::Essay.new(
  text: "Ethical Considerations in End-of-Life Care",
  data: essay_question_data
)
essay_question_1.subjects << subjects.sample(rand(1..3))
questions << essay_question_1

essay_question_data_2 = {
  "html" => <<~HTML
    <div class="question-introduction">
      <h3>Leadership and Change Management in Nursing Practice</h3>

      <p>Healthcare environments are constantly evolving due to advances in technology, evidence-based practice guidelines, regulatory requirements, and shifting population health needs. Effective nurse leaders must develop competencies in change management to successfully implement and sustain improvements in patient care delivery.</p>

      <p>Change theories such as Lewin's Three-Step Model (Unfreezing-Change-Refreezing) and Kotter's 8-Step Process provide frameworks for understanding the dynamics of organizational change. However, implementing change in healthcare settings presents unique challenges, including professional autonomy concerns, interdisciplinary collaboration requirements, and the direct impact on patient outcomes.</p>

      <p>Nurse leaders must anticipate and address barriers to change, which may include resistance from staff, resource limitations, organizational culture factors, and competing priorities within the healthcare system.</p>
    </div>

    <div class="question-prompt">
      <p>You are the nurse manager of a medical-surgical unit that has experienced an increase in hospital-acquired pressure injuries (HAPIs) over the past six months. Your quality improvement data indicates inconsistent implementation of the pressure injury prevention protocol, particularly during shift changes and periods of high unit acuity. The hospital administration has prioritized reducing HAPIs and has asked you to lead a quality improvement initiative on your unit.</p>

      <p><strong>Develop a comprehensive change management plan to address this issue. Your essay should include:</strong></p>
      <ul>
        <li>Analysis of potential barriers to implementing pressure injury prevention best practices</li>
        <li>Application of a specific change theory to guide your implementation strategy</li>
        <li>Methods for engaging staff in the change process</li>
        <li>Specific leadership approaches you would utilize</li>
        <li>Strategies for evaluating the effectiveness of your intervention</li>
        <li>Plan for sustaining positive changes long-term</li>
      </ul>

      <p>Your response should demonstrate understanding of evidence-based leadership principles and change management strategies in the context of nursing practice.</p>
    </div>
  HTML
}

essay_question_2 = Question::Essay.new(
  text: "Leadership and Change Management in Nursing Practice",
  data: essay_question_data_2
)
essay_question_2.subjects << subjects.sample(rand(1..3))
questions << essay_question_2

select_all_question_3_data = [
  { "answer" => "Elevate the limb above the level of the heart", "correct" => true },
  { "answer" => "Apply warm compresses to the affected area", "correct" => false },
  { "answer" => "Assess distal pulses, sensation, and capillary refill", "correct" => true },
  { "answer" => "Administer prescribed anticoagulants as ordered", "correct" => true },
  { "answer" => "Encourage ambulation to improve circulation", "correct" => false }
]

select_all_question_3 = Question::SelectAllThatApply.new(
  text: "The image shows a patient with deep vein thrombosis (DVT) of the left leg. Which nursing interventions are appropriate for this patient? Select all that apply.",
  data: select_all_question_3_data
)

image = select_all_question_3.images.build(alt_text: "Image of left leg showing redness, swelling, and edema characteristic of deep vein thrombosis (DVT)")
image.file.attach(io: File.open("db/seed_images/dog-injured.jpg"), filename: "dog-injured.jpg", content_type: "image/jpeg")
select_all_question_3.subjects << subjects.sample(rand(1..3))
questions << select_all_question_3


drag_drop_1_data = [
  { "answer" => "Systolic", "correct" => 1 },
  { "answer" => "Diastolic", "correct" => 2 },
  { "answer" => "Mean arterial", "correct" => 3 },
  { "answer" => "Pulse", "correct" => false },
  { "answer" => "Venous", "correct" => false }
]

drag_drop_1 = Question::DragAndDrop.new(
  text: "Blood pressure measurement consists of two values: ___1___ pressure, which represents the force during cardiac contraction, and ___2___ pressure, which represents the force when the heart is relaxed. The ___3___ pressure is an overall indicator of tissue perfusion.",
  data: drag_drop_1_data
)
drag_drop_1.subjects << subjects.sample(rand(1..3))
questions << drag_drop_1

drag_drop_2_data = [
  { "answer" => "Altered Level of Consciousness", "correct" => true },
  { "answer" => "Focal Neurological Deficits", "correct" => true },
  { "answer" => "Headache", "correct" => true },
  { "answer" => "Vomiting", "correct" => true },
  { "answer" => "Hypertension", "correct" => false },
  { "answer" => "Tachycardia", "correct" => false },
  { "answer" => "Fever", "correct" => false }
]

drag_drop_2 = Question::DragAndDrop.new(
  text: "Drag the clinical manifestations that are consistent with increased intracranial pressure (ICP) as shown in the CT scan image.",
  data: drag_drop_2_data
)

image = drag_drop_2.images.build(alt_text: "CT scan showing increased intracranial pressure with midline shift")
image.file.attach(io: File.open("db/seed_images/brain.jpg"), filename: "brain.jpg", content_type: "image/jpeg")
drag_drop_2.subjects << subjects.sample(rand(1..3))
questions << drag_drop_2

categorization_question_1_data = [
  {
    "answer" => "Sympathetic Nervous System Response",
    "correct" => ["Increased heart rate", "Pupil dilation", "Bronchodilation", "Decreased GI motility"]
  },
  {
    "answer" => "Parasympathetic Nervous System Response",
    "correct" => ["Decreased heart rate", "Pupil constriction", "Bronchoconstriction", "Increased GI motility"]
  }
]

categorization_question_1 = Question::Categorization.new(
  text: "Categorize each physiological response according to whether it is primarily mediated by the sympathetic or parasympathetic nervous system:",
  data: categorization_question_1_data
)
categorization_question_1.subjects << subjects.sample(rand(1..3))
questions << categorization_question_1

categorization_question_2_data = [
  {
    "answer" => "Early Signs of Shock",
    "correct" => ["Tachycardia", "Tachypnea", "Anxiety", "Decreased urine output"]
  },
  {
    "answer" => "Late Signs of Shock",
    "correct" => ["Hypotension", "Altered mental status", "Metabolic acidosis", "Cold, clammy skin"]
  }
]

categorization_question_2 = Question::Categorization.new(
  text: "Categorize each clinical manifestation according to whether it is an early or late sign of shock:",
  data: categorization_question_2_data
)
categorization_question_2.subjects << subjects.sample(rand(1..3))
questions << categorization_question_2

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
  data: bow_tie_question_1_data
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
  data: bow_tie_question_2_data
)
bow_tie_question_2.subjects << subjects.sample(rand(1..3))
questions << bow_tie_question_2

# First Stimulus Case Study - Respiratory Distress Case
stimulus_case_study_question_1 = Question::StimulusCaseStudy.new(
  text: "Respiratory Distress in a Geriatric Patient"
)
stimulus_case_study_question_1.subjects << subjects.sample(rand(1..3))

# Create a scenario as the first child
stimulus_case_study_1_scenario = Question::Scenario.new(
  text: "Mr. Henderson, a 78-year-old male, presents to the emergency department with complaints of progressive shortness of breath over the past 3 days. He reports a productive cough with yellow-green sputum and a fever of 101.2°F (38.4°C) at home this morning. His medical history includes COPD, hypertension, and type 2 diabetes. He uses supplemental oxygen at home (2L/min via nasal cannula). On assessment, vital signs are: BP 148/92 mmHg, HR 110 bpm, RR 28/min, SpO2 88% on room air, and temperature 38.6°C. Lung auscultation reveals diminished breath sounds in the right lower lobe with crackles and wheezing.",
  parent_question: stimulus_case_study_question_1
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
  child_of_aggregation: true
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
  child_of_aggregation: true
)

image = stimulus_case_study_select_all_1.images.build(alt_text: "Chest X-ray showing right lower lobe infiltrate and pleural effusion")
image.file.attach(io: File.open("db/seed_images/chest-xray.jpg"), filename: "chest-xray.jpg", content_type: "image/jpeg")

stimulus_case_study_question_1.as_parent_question_aggregations.build(presentation_order: 2, child_question: stimulus_case_study_select_all_1)

# Add another scenario
stimulus_case_study_1_scenario_2 = Question::Scenario.new(
  text: "After initial assessment, Mr. Henderson is diagnosed with community-acquired pneumonia with acute hypoxemic respiratory failure. The physician has ordered oxygen therapy, IV antibiotics, and chest physiotherapy.",
  parent_question: stimulus_case_study_question_1
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
  child_of_aggregation: true
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
  child_of_aggregation: true
)
stimulus_case_study_question_1.as_parent_question_aggregations.build(presentation_order: 5, child_question: stimulus_case_study_matching)

questions << stimulus_case_study_question_1

# Second Stimulus Case Study - Neurological Assessment Case
stimulus_case_study_2 = Question::StimulusCaseStudy.new(
  text: "Neurological Assessment Following Trauma"
)
stimulus_case_study_2.subjects << subjects.sample(rand(1..3))

# Create a scenario as the first child
stimulus_case_study_2_scenario = Question::Scenario.new(
  text: "Emily Chen, a 24-year-old female, is brought to the emergency department by ambulance following a motor vehicle collision. She was the restrained driver and airbags deployed. On arrival, she is conscious but confused about the events. Initial assessment reveals a large contusion on her forehead, unequal pupils (right 5mm, left 3mm), and weakness in her left arm and leg. Vital signs: BP 160/95 mmHg, HR 100 bpm, RR 22/min, SpO2 97% on room air, GCS 13 (E3, V4, M6).",
  parent_question: stimulus_case_study_2
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
  child_of_aggregation: true
)
stimulus_case_study_2.as_parent_question_aggregations.build(presentation_order: 1, child_question: stimulus_case_study_2_bow_tie)

# Add another scenario
stimulus_scenario_2 = Question::Scenario.new(
  text: "A CT scan is performed, revealing a small subdural hematoma with minimal midline shift. Emily is admitted to the ICU for close monitoring. Six hours after admission, the nurse notes that Emily's level of consciousness has decreased, with a GCS now at 10 (E2, V3, M5). Her right pupil is now 6mm and minimally reactive to light.",
  parent_question: stimulus_case_study_2
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
  child_of_aggregation: true
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
  child_of_aggregation: true
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
  child_of_aggregation: true
)
stimulus_case_study_2.as_parent_question_aggregations.build(presentation_order: 5, child_question: stimulus_case_study_2_essay)

questions << stimulus_case_study_2

questions.shuffle.each(&:save)
Rails.logger.info("#{questions.size} questions were created")
