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

  default = "/subscriptions/a4b11da3-2642-4ae2-b8e0-ba40545a13d6/resourceGroups/ODL-clouddevops-218998/providers/Microsoft.Compute/images/myUbuntuPackerImage"
}

variable "vm_num" {
  description = "Number of virtual machines for deployment"
  type        = number

  default = 3
}
