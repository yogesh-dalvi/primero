protection_concern_fields = [
  Field.new({"name" => "protection_concern_type",
    "type" => "select_box",
    "display_name_all" => "Type of Protection Concern",
    "option_strings_text_all" => [
      "Sexually Exploited",
      "GBV survivor",
      "Trafficked/smuggled",
      "Statelessness",
      "Arrested/Detained",
      "Migrant",
      "Disabled",
      "Serious health issue",
      "Refugee",
      "CAAFAG",
      "Street child",
      "Child Mother",
      "Physically or Mentally Abused",
      "Living with vulnerable person",
      "Word Forms of Child Labor",
      "Child Headed Household",
      "Mentally Distressed",
      "Other",
      "Child harassed/intimidated (by group)",
      "Community rejection",
      "Community stigma",
      "Drug/Substance Abuse",
      "Early marriage",
      "Family received visits/harassed/intimidated (by group)",
      "Family rejection",
      "In conflict with the law",
      "Inability to meet basic needs",
      "Lack of Registration Card (UNHCR, IRCR, IRC, other)",
      "Medical/Health problem(s)",
      "Not attending school",
      "Pregnant",
      "Received Threats (from Group)",
      "Risk of abuse & exploitation",
      "Risk of arrest",
      "Risk of recruitment by armed group",
      "Security"
    ].join("\n")
  }),
  Field.new({"name" => "date_concern_identified",
    "type" => "select_box",
    "display_name_all" => "Period when identified?",
    "option_strings_text_all" => [
      "Follow-up After Reunification",
      "Follow-up In Care",
      "Registration",
      "Reunification",
      "Verification"
    ].join("\n")
  }),
  Field.new({"name" => "concern_details",
    "type" => "text_field",
    "display_name_all" => "Details of the concern"
  }),
  Field.new({"name" => "concern_intervention_needed",
    "type" => "select_box",
    "display_name_all" => "Intervention needed?",
    "option_strings_text_all" => [
      "No Further Action Needed", 
      "Ongoing Monitoring", 
      "Urgent Intervention"
    ].join("\n")
  }),
  Field.new({"name" => "date_concern_intervention_needed_by",
    "type" => "date_field",
    "display_name_all" => "Intervention needed by"
  }),
  Field.new({"name" => "concern_action_taken_already",
    "type" => "select_box",
    "display_name_all" => "Has action been taken?",
    "option_strings_text_all" => "Yes\nNo"
  }),
  Field.new({"name" => "concern_action_taken_details",
    "type" => "text_field",
    "display_name_all" => "Details of Action Taken"
  }),
  Field.new({"name" => "concern_action_taken_date",
    "type" => "date_field",
    "display_name_all" => "Date when action was taken"
  })
]

FormSection.create_or_update_form_section({
  :unique_id => "protection_concern",
  "visible" => true,
  :order => 16,
  :fields => protection_concern_fields,
  :perm_visible => true,
  "editable" => true,
  "name_all" => "Protection Concern",
  "description_all" => "Protection concerns"
})