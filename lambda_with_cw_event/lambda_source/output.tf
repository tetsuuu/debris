output "lambda_archive" {
  value = data.archive_file.archived_source.output_path
}

output "lambda_hash" {
  value = data.archive_file.archived_source.output_base64sha256
}
