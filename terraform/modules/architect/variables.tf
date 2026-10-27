variable "prefix" {
  type = string
}

variable "flows_dir" {
  type = string
}

variable "division_name" {
  description = "Division the flows are created in. Genesys flows live in a division, like everything else."
  type        = string
}

variable "division_id" {
  description = "ID of that division, for data tables."
  type        = string
}

variable "queue_names" {
  description = "Queue key to full queue name. Flows refer to queues by name."
  type        = map(string)
}

variable "schedule_group_ids" {
  description = "Schedule group key to ID, from the routing module."
  type        = map(string)
}

variable "flows" {
  description = "Flow templates. Key is a short name. file is the YAML in the flows folder. name is the display name."
  type = map(object({
    file = string
    name = string
  }))
}

variable "lines" {
  description = "Inbound numbers. Each names its flows per hours state and which schedule group decides the hours state."
  type = map(object({
    description    = string
    dnis           = list(string)
    open_flow      = string
    closed_flow    = optional(string)
    holiday_flow   = optional(string)
    schedule_group = string
    surge_override = optional(bool, false)
  }))
}

variable "surge_flow" {
  description = "Key of the flow that the emergency group sends the overridden lines to."
  type        = string
}

variable "event_workflow" {
  description = "Key of the workflow flow started by the contact-ended trigger."
  type        = string
}

variable "surge_mode_enabled" {
  description = "Surge switch. When true, the emergency group sends the overridden lines to the surge flow."
  type        = bool
}

variable "surge_notices" {
  description = "Notice code to announcement text for the surge data table. Fictional exercise data."
  type        = map(string)
}

variable "enable_event_trigger" {
  description = "Run the event workflow whenever a customer leaves a conversation. Off by default, because the scaffold workflow does nothing yet."
  type        = bool
  default     = false
}
