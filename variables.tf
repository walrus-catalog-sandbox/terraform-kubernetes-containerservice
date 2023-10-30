#
# Contextual Fields
#

variable "context" {
  type        = map(any)
  description = "(Optional) Receive contextual information. When Walrus deploys, Walrus will inject specific contextual information into this field."
  default     = {}
}
