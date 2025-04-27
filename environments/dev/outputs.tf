# environments/dev/outputs.tf

output "app_assets_s3_bucket_name" {
  description = "Name (ID) of the S3 bucket created for application assets."
  value       = module.app_assets_s3_bucket.bucket_id
}

output "app_assets_s3_bucket_arn" {
  description = "ARN of the S3 bucket created for application assets."
  value       = module.app_assets_s3_bucket.bucket_arn
}

output "route53_zone_id" {
  description = "The ID of the primary Route 53 public hosted zone."
  value       = aws_route53_zone.primary.zone_id
}

output "route53_zone_name_servers" {
  description = "List of Name Servers for the primary Route 53 hosted zone. **Action Required:** Update these NS records at your domain registrar."
  value       = aws_route53_zone.primary.name_servers
}

output "ses_domain_identity_arn" {
  description = "ARN of the SES domain identity created for the primary domain."
  value       = aws_ses_domain_identity.primary.arn
}

output "ses_verification_status_note" {
    description = "Reminder to check SES verification status in the AWS Console."
    value       = "AWS SES domain verification relies on DNS propagation of the TXT and CNAME records created. This can take minutes to hours. Please check the SES console in region ${var.aws_region} for the verification status of '${var.domain_name}'."
}