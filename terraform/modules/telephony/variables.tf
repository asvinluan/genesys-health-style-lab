variable "prefix" {
  type = string
}

variable "address" {
  description = "Head-office address. Genesys needs a location with an emergency number before a site can be created."
  type = object({
    street1  = string
    city     = string
    state    = string
    country  = string
    zip_code = string
  })
}

variable "emergency_number" {
  description = "The outbound caller ID used when a person at this site calls emergency services (000). Must be a number you own."
  type        = string
}

variable "site_caller_id" {
  description = "Default outbound caller ID for the site, in E.164 format."
  type        = string
}

variable "did_range_start" {
  description = "First number in the range your carrier gave you, E.164."
  type        = string
}

variable "did_range_end" {
  description = "Last number in the range, E.164."
  type        = string
}

variable "media_region" {
  description = "Where media (the voice itself) is handled. ap-southeast-2 is Sydney."
  type        = string
}

variable "carrier_label" {
  description = "A human label for the SIP trunk, for example the carrier name."
  type        = string
}

variable "caller_name" {
  description = "Name shown to people the site calls."
  type        = string
}
