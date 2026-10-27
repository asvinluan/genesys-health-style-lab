output "evaluation_form_id" {
  value = genesyscloud_quality_forms_evaluation.main.id
}

output "survey_form_id" {
  value = genesyscloud_quality_forms_survey.post_contact.id
}

output "retention_policy_id" {
  value = genesyscloud_recording_media_retention_policy.voice.id
}
