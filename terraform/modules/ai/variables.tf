variable "prefix" {
  type = string
}

variable "kb_name" {
  type = string
}

variable "kb_category" {
  type = string
}

variable "kb_tool_description" {
  type = string
}

variable "agent_role" {
  description = "One paragraph telling the virtual agent what it is for. Scope is the first guardrail."
  type        = string
}

variable "agent_instructions" {
  description = "Behaviour rules, one per line."
  type        = list(string)
}

variable "guardrails" {
  description = "Custom guardrail rules. Each blocks a kind of request before the agent answers."
  type        = list(string)
}

variable "exit_message" {
  type = string
}

variable "escalation_message" {
  type = string
}

variable "guardrail_message" {
  type = string
}

variable "threshold_message" {
  type = string
}

variable "guardrail_violation_threshold" {
  description = "How many policy violations in one conversation before the virtual agent ends the session and hands to a person."
  type        = number
  default     = 3
}

variable "faq" {
  description = "Knowledge articles for the virtual agent and for agent assist. Key is the article title, value is the answer text."
  type        = map(string)
}

variable "topics" {
  description = "Speech and text analytics topics: name to a list of phrases to spot in conversations."
  type        = map(list(string))
}
