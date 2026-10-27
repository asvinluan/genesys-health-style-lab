# Quality, recording and workforce management.
# AWS Connect lab equivalents:
#   Contact Lens evaluation forms      -> evaluation form
#   Post-contact survey                -> survey form
#   S3 lifecycle rules on recordings   -> media retention policy (archive then delete)
#   Connect forecasting and scheduling -> WFM business unit

resource "genesyscloud_quality_forms_evaluation" "main" {
  name      = "${var.prefix} ${var.evaluation_name}"
  published = true

  dynamic "question_groups" {
    for_each = var.evaluation_groups

    content {
      name       = question_groups.value.name
      weight     = question_groups.value.weight
      na_enabled = false

      dynamic "questions" {
        for_each = question_groups.value.questions

        content {
          text              = questions.value.text
          help_text         = questions.value.help_text
          is_critical       = questions.value.is_critical
          is_kill           = questions.value.is_kill
          comments_required = questions.value.is_kill

          answer_options {
            text  = "Yes"
            value = 1
          }
          answer_options {
            text  = "No"
            value = 0
          }
        }
      }
    }
  }
}

resource "genesyscloud_quality_forms_survey" "post_contact" {
  name      = "${var.prefix} Post-Contact Survey"
  published = true
  disabled  = false
  language  = "en-US"
  header    = "Tell us how we did"
  footer    = "Thank you. Your feedback helps us improve our service."

  question_groups {
    name       = "Experience"
    na_enabled = false

    questions {
      text                    = "How easy was it to get the help you needed?"
      type                    = "npsQuestion"
      na_enabled              = false
      max_response_characters = 200
      explanation_prompt      = "What is the main reason for your score?"
    }

    questions {
      text       = "Was your enquiry resolved today?"
      type       = "multipleChoiceQuestion"
      na_enabled = false

      answer_options {
        text  = "Yes"
        value = 1
      }
      answer_options {
        text  = "No"
        value = 0
      }
    }
  }
}

# Recording retention: keep fast for archive_days, archive, delete at delete_days.
# The number of days comes from the agency's records authority, not from engineering.
resource "genesyscloud_recording_media_retention_policy" "voice" {
  name        = "${var.prefix} Voice Retention"
  description = "Archive then delete recorded calls. Days are set in variables and must follow the records authority."
  enabled     = true
  order       = 0

  media_policies {
    call_policy {
      actions {
        retain_recording = true

        retention_duration {
          archive_retention {
            days           = var.archive_days
            storage_medium = "CLOUDARCHIVE"
          }
          delete_retention {
            days = var.delete_days
          }
        }
      }

      conditions {
        for_queue_ids = [for k in var.recorded_queue_keys : var.queue_ids[k]]
      }
    }
  }
}

resource "genesyscloud_recording_settings" "this" {
  recording_playback_url_ttl = 30
}

# Workforce management: forecasting and scheduling for the contact centre.
resource "genesyscloud_workforcemanagement_businessunits" "main" {
  name        = "${var.prefix} Business Unit"
  division_id = var.home_division_id

  settings {
    start_day_of_week = "Monday"
    time_zone         = var.time_zone

    short_term_forecasting {
      default_history_weeks = 8
    }
  }
}
