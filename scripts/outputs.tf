output "base_url" {

  value = aws_apigatewayv2_stage.lambda.invoke_url
}

output "route53_url" {

  value = aws_route53_record.image_resizer.fqdn
}