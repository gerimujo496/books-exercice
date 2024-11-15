variable "domain_name" {
    description = "domian name in cloudfront origin"
  type = string
}

variable "bucket" {

    description = "bucket in default cache behavior"
  type = string
}

variable "document_suffix" {
  description = "document suffix"
  type = string
 
}

