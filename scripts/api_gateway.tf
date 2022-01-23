# API Gateway code for uploading images to resize
resource "aws_apigatewayv2_api" "lambda" {
  name = "${local.general_resource_name}-gateway-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "lambda" {
  api_id = aws_apigatewayv2_api.lambda.id

  name = "${local.general_resource_name}gateway-stage"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gw.arn
    format = jsonencode({
      requestId               = "$context.requestId"
      sourceIp                = "$context.identity.sourceIp"
      requestTime             = "$context.requestTime"
      protocol                = "$context.protocol"
      httpMethod              = "$context.httpMethod"
      resourcePath            = "$context.resourcePath"
      routeKey                = "$context.routeKey"
      status                  = "$context.status"
      responseLength          = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
      }
    )
  }
}

resource "aws_cloudwatch_log_group" "api_gw" {
  name = "${local.general_resource_name}cloudwatch-group"

  retention_in_days = 30
}

resource "aws_apigatewayv2_integration" "image_resizer" {
  api_id = aws_apigatewayv2_api.lambda.id
  integration_type = "HTTP_PROXY"
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "image_resizer" {
  api_id = aws_apigatewayv2_api.lambda.id

  route_key = "POST /image"
  target = "integrations/${aws_apigatewayv2_integration.image_resizer.id}"
}

resource "aws_acm_certificate" "cert" {
  domain_name       = var.domain
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.image_resizer : record.fqdn]
}

resource "aws_apigatewayv2_domain_name" "image_resizer" {
  domain_name = local.domain_name
  domain_name_configuration {
    certificate_arn = aws_acm_certificate.cert.arn
    endpoint_type = "REGIONAL"
    security_policy = "TLS_1_2"
  }
}

data "aws_route53_zone" "zone" {
  name  = "aircall.com"
  private_zone = false
}

resource "aws_route53_record" "image_resizer" {
  name = var.domain
  type = "A"
  zone_id = data.aws_route53_zone.zone.id
  alias {
    evaluate_target_health = false
    name = aws_apigatewayv2_domain_name.image_resizer.domain_name
    zone_id = aws_apigatewayv2_domain_name.image_resizer.id
  }
}

resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.lambda.execution_arn}/*/*"}

resource "aws_cloudfront_distribution" "image_resizer" {
  enabled = true
  default_cache_behavior {
    allowed_methods = ["POST", "GET"]
    cached_methods = []
    target_origin_id = ""
    viewer_protocol_policy = ""
    forwarded_values {
      query_string = false
      cookies {
        forward = ""
      }
    }
  }
  origin {
    domain_name = aws_apigatewayv2_api.lambda.api_endpoint
    origin_id = ""
  }
  restrictions {
    geo_restriction {
      restriction_type = ""
    }
  }
  viewer_certificate {}
}