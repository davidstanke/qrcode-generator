# qrcode-generator

Terraform to create a QR Code generator using Cloud Functions

## Requirements
Terraform 1.0 or higher

## How to use
1. Create a GCP project (or select an existing one)
1. Edit `terraform.tfvars`: replace the values with appropriate values for your project
1. run `terraform init`
1. run `terraform apply`
  * enter `yes` when prompted

...when the `apply` command completes, you'll see an output named `qrcode_generator_endpoint`. This is the URL to your QR Code generator service.

To use it, make a GET request to that URL, with a query parameter named `qrtext` to specify the desired text/URL for the QR code.

> Example: `https://<qrcode_generator_endpoint>?qrtext=hello+world`