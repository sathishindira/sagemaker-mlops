variable "mlops_bucket_name" {
    default = "sagemaker-mlops-sathish-01"
    type = string
}

variable "mlflow_bucket_name" {
    default = "sagemaker-mlflow-sathish-01"
    type = string
}

variable "tags" {
    default = {
        Environment = "prod"
        Owner       = "Sathish"
        app = "mlops"
        }
    type = map(string)
  
}

variable "vpc_cidr" {
    default = "10.0.0.0/16"
    type = string
  
}

variable "name" {
  default = "MLops"
  type = string
}

variable "db_password" {
  default = "Hello@2024"
  sensitive = true
}