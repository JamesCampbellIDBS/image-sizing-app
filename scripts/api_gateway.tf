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

resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.lambda.execution_arn}/*/*"}

resource "aws_cloudfront_distribution" "image_resizer" {
  enabled = true
  default_cache_behavior {
    allowed_methods = ["POST"]
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