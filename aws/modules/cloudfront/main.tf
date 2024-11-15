resource "aws_cloudfront_distribution" "cloudfront_distribution" {
  enabled = true
  is_ipv6_enabled = true
  default_root_object = var.document_suffix
  

  origin {
    domain_name = var.domain_name
origin_id = "geri007"
 custom_origin_config {
   origin_protocol_policy = "http-only"
   origin_ssl_protocols = ["TLSv1.2"]
   http_port = 80
   https_port = 443
 }

}

custom_error_response {
  error_code = 404
  response_code = 404
  
}


restrictions {
  geo_restriction {
    restriction_type = "none"
    locations = []
  }
}

default_cache_behavior {
  viewer_protocol_policy = "redirect-to-https"

  allowed_methods = ["GET", "HEAD"]
  cached_methods = ["GET", "HEAD"]
  target_origin_id = var.bucket

   compress = true


   forwarded_values {
     query_string =  false

     cookies {
       forward = "none"
     }
   }
}
viewer_certificate {
 cloudfront_default_certificate = true
}

}

