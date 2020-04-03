locals {
  mime_types = {
    htm   = "text/html"
    html  = "text/html"
    css   = "text/css"
    ttf   = "font/ttf"
    js    = "application/javascript"
    map   = "application/javascript"
    json  = "application/json"
    woff  = "font/woff"
    woff2 = "font/woff2"
    mp3   = "audio/mpeg"
    ico   = "image/x-icon"
    eot   = "application/vnd.ms-fontobject"

    svg = "image/svg+xml"
  }

  build_dir = "${data.external.frontend_build.working_dir}/${data.external.frontend_build.result.dest}/"
}

data "external" "frontend_build" {
  program = ["bash", "-c", <<EOT
(npm ci && npm run build-prod) >&2 && echo "{\"dest\": \"../build/static\"}"
EOT
  ]
  working_dir = "${path.module}/../../ui"
}

resource "aws_s3_bucket_object" "upload_files" {
  for_each = fileset(local.build_dir, "**/*.*")

  bucket       = var.static_bucket_name
  key          = each.value
  source       = "${local.build_dir}${each.value}"
  etag         = filemd5("${local.build_dir}${each.value}")
  content_type = lookup(local.mime_types, split(".", each.value)[length(split(".", each.value)) - 1])
}