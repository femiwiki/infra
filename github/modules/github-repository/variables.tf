# Repository
variable "name" {
  description = ""
  type        = string
}

variable "description" {
  description = ""
  type        = string
}

variable "homepage_url" {
  description = ""
  type        = string
  default     = ""
}

variable "topics" {
  description = ""
  type        = list(string)
  default     = []
}

variable "delete_branch_on_merge" {
  description = ""
  type        = bool
  default     = true
}

# Branch protection
variable "patterns" {
  description = ""
  type        = list(string)
  default     = ["main"]
}

variable "enforce_admins" {
  description = ""
  type        = bool
  default     = false
}

variable "required_pull_request_reviews" {
  description = ""
  type = list(object({
    dismiss_stale_reviews           = bool,
    require_code_owner_reviews      = bool,
    required_approving_review_count = number,
  }))
  default = [
    {
      dismiss_stale_reviews           = false,
      require_code_owner_reviews      = false,
      required_approving_review_count = 1,
    }
  ]
}

variable "required_status_checks_contexts" {
  description = ""
  type        = list(list(string))
  default     = []
}

variable "collaborator" {
  type    = bool
  default = false
}
