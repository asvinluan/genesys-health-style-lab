variable "prefix" {
  description = "Short name prefix for every object, for example DH. Keeps lab objects easy to find and delete."
  type        = string
}

variable "divisions" {
  description = "Divisions to create. A division is the access-control boundary: roles are granted per division."
  type        = map(string)
}

variable "skills" {
  description = "Routing skills (what an agent can do). Product and capability skills, not one queue per skill."
  type        = list(string)
}

variable "languages" {
  description = "Routing languages (which language an agent speaks)."
  type        = list(string)
}

variable "wrapup_codes" {
  description = "Wrap-up codes (call outcome) as a map of name to description."
  type        = map(string)
}

variable "groups" {
  description = "Official groups used for queue membership and role grants."
  type        = map(string)
}

variable "roles" {
  description = "Custom roles: name to description and permission list."
  type = map(object({
    description = string
    permissions = list(string)
  }))
}

variable "group_roles" {
  description = "Which roles each group gets, and which divisions it is kept out of."
  type = map(object({
    roles             = list(string)
    exclude_divisions = optional(list(string), [])
  }))
}

variable "integration_role_name" {
  description = "Name of the role given to the data-action OAuth client. Keep it the smallest role in the list."
  type        = string
}

variable "presence_label" {
  description = "Label of the one custom presence status."
  type        = string
}
