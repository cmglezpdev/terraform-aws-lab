resource "aws_s3_bucket" "state" {
  bucket = "tf-state-learning-course-terraform"

  lifecycle {
    prevent_destroy = true
  }
}


resource "aws_s3_bucket_versioning" "state" {
  bucket = aws_s3_bucket.state.id

  # Esta es la copia de seguridad del state. HashiCorp lo llama
  # "highly recommended"; en la práctica es obligatorio.
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "state" {
  bucket = aws_s3_bucket.state.id

  # Redundante: los buckets nuevos ya nacen así desde 2023.
  # Se escribe igual, por dos razones: deja la intención por escrito,
  # y hace que el plan detecte si alguien lo desactiva a mano.
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

output "state_bucket" {
  description = "Bucket for storing the state of all projects"
  value       = aws_s3_bucket.state.id
}