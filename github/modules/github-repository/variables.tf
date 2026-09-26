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

variable "required_status_checks_strict" {
  description = "Require the branch to be up to date with its base before merging"
  type        = bool
  default     = false
}

variable "required_status_checks_contexts" {
  description = "Repo-specific required status checks (org-wide ones are added automatically)"
  type        = list(string)
  default     = []
}

variable "push_allowances" {
  description = "Actors that may push to the protected branches, apps as \"/slug\". Empty leaves pushing unrestricted."
  type        = list(string)
  default     = []
}

variable "default_status_checks" {
  description = "Status checks required on every repo unless overridden"
  type        = list(string)
  default     = ["zizmor"]
}

variable "pages_build_type" {
  description = "GitHub Pages build source, e.g. \"workflow\". Null leaves Pages off."
  type        = string
  default     = null
}

variable "pages_cname" {
  description = "The domain Pages answers on, written to the branch as CNAME. Null leaves the default."
  type        = string
  default     = null
}

variable "collaborator" {
  type    = bool
  default = false
}

variable "archived" {
  description = "Archive the repository. To bring it back, unarchive it in GitHub first, then set this back to false."
  type        = bool
  default     = false
}
