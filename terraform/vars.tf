variable "required_tag" {
  description = "tags needed for resources creation"
  type        = map(any)

  default = {
    role = "devops"
  }
}

variable "image_id" {
  description = "id of vm image from packer"
  type        = string

  default = "/subscriptions/9264ae45-f6c6-47e0-9199-fa1b3e14415e/resourceGroups/ODL-clouddevops-218472/providers/Microsoft.Compute/images/myUbuntuPackerImage"
}

variable "vm_num" {
  description = "Number of virtual machines for deployment"
  type        = number

  default = 3
}
