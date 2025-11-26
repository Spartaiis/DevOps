resource "null_resource" "gateway_debug" {
  # Cette ressource ne fait rien sur AWS, elle sert juste de placeholder
  triggers = {
    function_arn = var.function_arn
  }

  provisioner "local-exec" {
    command = "echo 'DEBUG: Module API Gateway chargé pour ${var.name}'"
  }
}