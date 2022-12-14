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

  default = "/subscriptions/80ae9245-22ea-4f16-a42f-d5cebd7aac99/resourceGroups/ODL-clouddevops-218348/providers/Microsoft.Compute/images/myUbuntuPackerImage"
}

variable "vm_num" {
  description = "Number of virtual machines for deployment"
  type        = number

  default = 1
}