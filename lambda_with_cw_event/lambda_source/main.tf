data "archive_file" "archived_source" {
  type        = "zip"
  source_file = "${path.module}/${var.lambda_file_name}"
  output_path = "${var.function_name}.lambda.zip"
}
