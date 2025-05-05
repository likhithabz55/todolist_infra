resource "kubernetes_secret" "rds_db_credentials" {
  metadata {
    name      = "rds-db-secret"
    namespace = "default"
  }

  data = {
    DB_HOST     = aws_db_instance.postgres.endpoint
    DB_PORT     = aws_db_instance.postgres.port
    DB_NAME     = aws_db_instance.postgres.db_name
    DB_USER     = aws_db_instance.postgres.username
    DB_PASSWORD = var.db_password  # Make sure this is securely passed in!
  }

  type = "Opaque"
}
