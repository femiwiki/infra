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
  default = []
}

variable "required_status_checks_contexts" {
  description = "Repo-specific required status checks (org-wide ones are added automatically)"
  type        = list(string)
  default     = []
}

variable "default_status_checks" {
  description = "Status checks required on every repo unless overridden"
  type        = list(string)
  default     = ["zizmor"]
}

variable "collaborator" {
  type    = bool
  default = false
}
