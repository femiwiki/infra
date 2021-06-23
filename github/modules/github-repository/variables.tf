# Repository
variable "name" {
  description = ""
  type        = string
}

variable "description" {
  description = ""
  type        = string
}

variable "topics" {
  description = ""
  type        = list(string)
}

# Branch protection
variable "patterns" {
  description = ""
  type        = list(string)
  default     = ["main"]
}

variable "enforce_admins" {
  description = ""
  type        = string
  default     = true
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
