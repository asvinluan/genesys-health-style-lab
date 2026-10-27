variable "prefix" {
  type = string
}

variable "flows_dir" {
  description = "Folder holding the Archy YAML templates."
  type        = string
}

variable "division_ids" {
  description = "Division name to ID, from the foundation module."
  type        = map(string)
}

variable "home_division_name" {
  description = "Name of the home division, used in flow YAML."
  type        = string
  default     = "Home"
}

variable "group_ids" {
  description = "Group name to ID, from the foundation module."
  type        = map(string)
}

variable "wrapup_code_ids" {
  description = "Wrap-up code name to ID."
  type        = map(string)
}

variable "queues" {
  description = "Queue definitions. Key is the queue name (without prefix)."
  type = map(object({
    description   = string
    division      = string
    base_group    = string
    overflow      = list(object({ after_seconds = number, group = string }))
    sla_percent   = number
    sla_seconds   = number
    acw_seconds   = number
    transcription = bool
    wrapup_codes  = list(string)
    calling_name  = string
    surge         = optional(list(object({ estimated_wait_seconds = number, group = string })), [])
  }))
}

variable "time_zone" {
  description = "IANA time zone for schedule groups."
  type        = string
}

variable "holidays" {
  description = "Public holidays that close the servicing line. Map of name to date (YYYY-MM-DD)."
  type        = map(string)
}

variable "open_schedules" {
  description = "Recurring open-hours schedules. Key is the name (without prefix)."
  type = map(object({
    description = string
    start       = string
    end         = string
    rrule       = string
  }))
}

variable "schedule_groups" {
  description = "Schedule groups. open lists keys of open_schedules. use_holidays attaches the public-holiday schedules."
  type = map(object({
    description  = string
    open         = list(string)
    use_holidays = bool
  }))
}

variable "last_ring_wait_seconds" {
  description = "How long the last named ring waits before the call goes to every agent in the queue."
  type        = number
  default     = 120
}
