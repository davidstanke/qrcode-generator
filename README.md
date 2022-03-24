# qrcode-generator
This repo provides Terraform code which will provision a QR Code generator using Google Cloud Functions. The function is exposed via an HTTPS endpoint which accepts text via querystring. It generates a QR Code as a PNG, stores it in Google Cloud Storage, and returns a JSON object containing the public URL of the QR Code.

## Requirements
Terraform 1.0 or higher
A GCP project

## How to use
1. Edit `terraform.tfvars`: replace the values with appropriate values for your project
1. run `terraform init`
1. run `terraform apply`
  * enter `yes` when prompted

...when the `apply` command completes, you'll see an output named `qrcode_generator_endpoint`. This is the URL to your QR Code generator service.

To use it, make a GET request to that URL, with a query parameter named `qrtext` to specify the desired text/URL for the QR code.

> Example: `https://<qrcode_generator_endpoint>?qrtext=hello+world`