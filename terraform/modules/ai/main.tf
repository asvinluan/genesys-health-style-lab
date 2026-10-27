# AI and its guardrails.
#
# AWS Connect lab equivalents:
#   Amazon Q in Connect knowledge base        -> Genesys knowledge base (agent assist and the virtual agent both read it)
#   Amazon Lex V2 bot                          -> Genesys virtual agent (this one is a generative, "agentic" agent)
#   Bedrock Guardrails: denied topics          -> custom guardrail rules on the virtual agent
#   Bedrock Guardrails: violation handling     -> the Guardrails event with a violation threshold
#   Bedrock grounding check                    -> the agent may only answer from the knowledge base tool
#   Contact Lens analytics and topics          -> Speech and Text Analytics topics and program
#   Contact Lens PII redaction                 -> transcription redaction in the foundation module
#   Bedrock post-contact summary               -> AI Studio summary setting
#
# Guardrails are layers, not one switch. See docs/ARCHITECTURE-BRIEF.md for the full stack.

# ---------------------------------------------------------------- knowledge base
resource "genesyscloud_knowledge_knowledgebase" "kb" {
  name                   = "${var.prefix} ${var.kb_name}"
  description            = "Approved answers only. Lab content paraphrased from public guidance; not authoritative."
  core_language          = "en-AU"
  content_search_enabled = true
}

resource "genesyscloud_knowledge_category" "main" {
  knowledge_base_id = genesyscloud_knowledge_knowledgebase.kb.id

  knowledge_category {
    name        = var.kb_category
    description = "Approved public information"
  }
}

resource "genesyscloud_knowledge_document" "faq" {
  for_each          = var.faq
  knowledge_base_id = genesyscloud_knowledge_knowledgebase.kb.id

  knowledge_document {
    title         = each.key
    visible       = true
    category_name = genesyscloud_knowledge_category.main.knowledge_category[0].name
  }
}

resource "genesyscloud_knowledge_document_variation" "faq" {
  for_each              = var.faq
  knowledge_base_id     = genesyscloud_knowledge_knowledgebase.kb.id
  knowledge_document_id = genesyscloud_knowledge_document.faq[each.key].id
  published             = true

  knowledge_document_variation {
    body {
      blocks {
        type = "Paragraph"

        paragraph {
          blocks {
            type = "Text"

            text {
              text = each.value
            }
          }
        }
      }
    }
  }
}

# ---------------------------------------------------------------- virtual agent with guardrails
resource "genesyscloud_agentic_virtual_agent" "assistant" {
  name = "${var.prefix} Virtual Assistant"
}

resource "genesyscloud_agentic_virtual_agent_version" "v1" {
  agent_id = genesyscloud_agentic_virtual_agent.assistant.id

  definition {
    role = var.agent_role

    # Layer 1: behaviour. What the agent is told to do and not do.
    instructions = var.agent_instructions

    # Layer 2: guardrails. Rules that detect and block user behaviour before the agent answers.
    guardrails {
      dynamic "custom" {
        for_each = var.guardrails

        content {
          instruction = custom.value
          enabled     = true
        }
      }
    }

    # Layer 3: grounding. The only information tool the agent has is the approved knowledge base.
    tools {
      type        = "KnowledgeBase"
      name        = "Approved answers"
      description = var.kb_tool_description

      target {
        id   = genesyscloud_knowledge_knowledgebase.kb.id
        name = genesyscloud_knowledge_knowledgebase.kb.name
      }

      input_instructions = ["Use for any factual question this service can answer."]
    }

    # Layer 4: what happens when a guardrail fires, and when to give up and hand over.
    events {
      type    = "UserExit"
      message = var.exit_message
    }

    events {
      type    = "Escalation"
      message = var.escalation_message
    }

    events {
      type                                = "Guardrails"
      message                             = var.guardrail_message
      violation_threshold                 = var.guardrail_violation_threshold
      violation_threshold_crossed_message = var.threshold_message
    }

    settings {
      comfort_statement {
        enabled = true
      }
    }
  }
}

# ---------------------------------------------------------------- post-contact summary
resource "genesyscloud_ai_studio_summary_setting" "summary" {
  name         = "${var.prefix} Concise Summary"
  language     = "en-au"
  summary_type = "Concise"
  setting_type = "Basic"
  format       = "BulletPoints"

  mask_p_i_i {
    all = true
  }

  participant_labels {
    internal = "Advisor"
    external = "Customer"
  }

  predefined_insights = []
  prompt              = ""
}

# ---------------------------------------------------------------- speech and text analytics
# Listens to every transcribed contact and tags the ones that matter: complaints, hardship, vulnerability.
resource "genesyscloud_speechandtextanalytics_topic" "this" {
  for_each     = var.topics
  name         = "${var.prefix} ${each.key}"
  dialect      = "en-AU"
  description  = "Detects: ${each.key}"
  strictness   = "72"
  participants = "All"
  tags         = ["lab"]

  dynamic "phrases" {
    for_each = each.value

    content {
      text       = phrases.value
      strictness = "72"
      sentiment  = "Neutral"
    }
  }
}

resource "genesyscloud_speechandtextanalytics_program" "main" {
  name        = "${var.prefix} Contact Quality Program"
  description = "Detects complaints, vulnerability, safety and scam topics for review"
  topic_ids   = [for t in genesyscloud_speechandtextanalytics_topic.this : t.id]
  tags        = ["lab"]
}

resource "genesyscloud_speechandtextanalytics_settings" "settings" {
  expected_dialects      = ["en-AU"]
  text_analytics_enabled = true
  agent_empathy_enabled  = false
  default_program_id     = genesyscloud_speechandtextanalytics_program.main.id
}
