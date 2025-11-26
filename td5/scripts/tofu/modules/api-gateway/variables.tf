variable "name" {
  description = "Le nom de l'API Gateway"
  type        = string
}

variable "function_arn" {
  description = "L'ARN de la fonction Lambda à invoquer"
  type        = string
}

variable "api_gateway_routes" {
  description = "La liste des routes (ex: ['GET /'])"
  type        = list(string)
  default     = []
}