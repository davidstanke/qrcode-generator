output "qrcode_generator_endpoint" {
  value = "${google_cloudfunctions_function.qrcode-generator.https_trigger_url}?qrtext=your+text+here"
}
