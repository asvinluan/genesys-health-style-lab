variable "prefix" {
  type = string
}

variable "home_division_id" {
  type = string
}

variable "time_zone" {
  type = string
}

variable "archive_days" {
  description = "Days a recording stays in fast storage before it moves to archive."
  type        = number
  default     = 90
}

variable "delete_days" {
  description = "Days until a recording is deleted. Set by your records policy and regulator, not by this lab. 2555 days is about 7 years."
  type        = number
  default     = 2555
}

variable "queue_ids" {
  description = "Queue key to ID. The retention policy applies to these queues only."
  type        = map(string)
}

variable "recorded_queue_keys" {
  description = "Which queue keys are recorded and retained."
  type        = list(string)
}

variable "evaluation_name" {
  type = string
}

variable "evaluation_groups" {
  description = "Evaluation form content. Questions are Yes or No. is_critical and is_kill mark the questions that matter most."
  type = list(object({
    name   = string
    weight = number
    questions = list(object({
      text        = string
      help_text   = string
      is_critical = bool
      is_kill     = bool
    }))
  }))
}
