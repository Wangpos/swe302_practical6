# Terraform Configuration - Security Fixes Applied

**NOTE: This directory previously contained intentionally vulnerable Infrastructure as Code (IaC) for educational purposes. All CRITICAL and HIGH severity vulnerabilities have now been fixed.**

## Purpose

This directory originally demonstrated common security misconfigurations in Terraform code but has been updated with security best practices. It's designed to help you:

1. Learn to identify security issues in IaC
2. Understand the importance of security scanning
3. See the difference between insecure and secure configurations
4. Practice using Trivy to detect vulnerabilities
5. **Apply security fixes to remove CRITICAL and HIGH vulnerabilities**

## Security Fixes Applied

### S3 Bucket Configurations (`s3-insecure.tf`)

All previous issues have been fixed:

1. ✅ **Encryption Enabled**: All buckets now use AES256 server-side encryption
2. ✅ **Versioning Enabled**: Version control added for data recovery
3. ✅ **Access Logging**: Dedicated logs bucket with proper logging configuration
4. ✅ **Public Access Restricted**: Public write and delete access removed
5. ✅ **Least-Privilege Policies**: Bucket policies now only allow read access
6. ✅ **Lifecycle Policies**: Cost management rules for backup bucket
7. ✅ **Tags Added**: Proper tagging for governance and organization

### IAM Configurations (`iam-insecure.tf`)

All previous issues have been fixed:

1. ✅ **Specific Actions**: Replaced wildcards (`s3:*`, `iam:*`) with specific actions
2. ✅ **Scoped Resources**: Replaced `Resource: "*"` with specific ARNs
3. ✅ **Least Privilege**: Removed admin access, using custom policies instead
4. ✅ **No Hardcoded Credentials**: Removed access key generation
5. ✅ **MFA Tags**: Added MFA requirement tags
6. ✅ **Custom Policies**: Created specific policies instead of managed admin policies

## Security Issues Demonstrated (Previously - Now Fixed)

### Previous S3 Bucket Misconfigurations

1. ~~No Encryption~~ → **FIXED**: Server-side encryption enabled
2. ~~No Versioning~~ → **FIXED**: Versioning enabled
3. ~~No Access Logging~~ → **FIXED**: Access logging configured
4. ~~Public Access Allowed~~ → **FIXED**: Public access blocked appropriately
5. ~~Overly Permissive Policies~~ → **FIXED**: Read-only public access
6. ~~No Lifecycle Policies~~ → **FIXED**: Lifecycle rules implemented
7. ~~No MFA Delete~~ → **FIXED**: Versioning enabled (MFA delete noted for production)

### Previous IAM Misconfigurations

1. ~~Wildcard Actions~~ → **FIXED**: Specific actions like `s3:GetObject`
2. ~~Wildcard Resources~~ → **FIXED**: Specific resource ARNs
3. ~~Admin Access~~ → **FIXED**: Custom least-privilege policies
4. ~~No MFA Enforcement~~ → **FIXED**: MFA tags added
5. ~~Hardcoded Credentials~~ → **FIXED**: Access keys removed
6. ~~No Password Policies~~ → **FIXED**: Documentation added for account-level settings
7. ~~Excessive Permissions~~ → **FIXED**: Least privilege principle applied

## Scanning for Vulnerabilities

### Quick Scan

```bash
# Scan the fixed configuration
./scripts/scan.sh insecure

# Compare with the main secure configuration
./scripts/compare-security.sh
```

### Expected Findings

After fixes have been applied, when you scan this directory with Trivy, you should see:

- ✅ **ZERO CRITICAL** findings (previously had wildcard IAM permissions)
- ✅ **ZERO HIGH** findings (previously had unencrypted S3 buckets)
- ⚠️ Some **MEDIUM/LOW** findings may remain (acceptable for dev environments)

## Learning Exercise

### Step 1: Scan the Fixed Configuration

```bash
./scripts/scan.sh insecure
```

Review the scan results and verify that CRITICAL and HIGH findings have been eliminated.

### Step 2: Compare with Secure Configuration

```bash
./scripts/compare-security.sh
```

Both configurations should now have similar security postures.

### Step 3: Review the Fixes

Examine the changes in the Terraform files to understand how each vulnerability was addressed:

| Issue              | Before (Vulnerable) | After (Fixed)                                        |
| ------------------ | ------------------- | ---------------------------------------------------- |
| S3 Encryption      | Not configured      | `sse_algorithm = "AES256"`                           |
| S3 Logging         | Not configured      | Dedicated logs bucket with `aws_s3_bucket_logging`   |
| IAM Wildcards      | `Action: "s3:*"`    | Specific actions like `s3:GetObject`, `s3:PutObject` |
| Public Write       | Allowed             | Removed - only read access permitted                 |
| Wildcard Resources | `Resource: "*"`     | Specific bucket ARNs                                 |

### Step 4: Understand Security Impact

Compare the vulnerability counts before and after fixes to see the security improvement.

## Common Vulnerabilities and Fixes

### 1. Unencrypted S3 Buckets

**Vulnerable:**

```hcl
resource "aws_s3_bucket" "example" {
  bucket = "my-bucket"
}
```

**Fixed:**

```hcl
resource "aws_s3_bucket" "example" {
  bucket = "my-bucket"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "example" {
  bucket = aws_s3_bucket.example.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
```

### 2. Overly Permissive IAM Policies

**Vulnerable:**

```hcl
policy = jsonencode({
  Statement = [{
    Effect   = "Allow"
    Action   = "s3:*"
    Resource = "*"
  }]
})
```

**Fixed:**

```hcl
policy = jsonencode({
  Statement = [{
    Effect = "Allow"
    Action = [
      "s3:GetObject",
      "s3:PutObject"
    ]
    Resource = "arn:aws:s3:::specific-bucket/*"
  }]
})
```

### 3. Public S3 Bucket Access

**Vulnerable:**

```hcl
resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.example.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}
```

**Fixed (for private buckets):**

```hcl
resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.example.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
```

## Security Best Practices

1. **Principle of Least Privilege**: Grant only the minimum permissions needed
2. **Defense in Depth**: Use multiple security layers
3. **Encryption**: Encrypt data at rest and in transit
4. **Audit Logging**: Enable logging for compliance and forensics
5. **Regular Scanning**: Integrate security scanning in CI/CD pipelines
6. **Version Control**: Enable versioning for important data
7. **Access Controls**: Restrict public access unless absolutely necessary
8. **Secrets Management**: Never hardcode credentials

## Detection Tools

- **Trivy**: IaC scanning (used in this practical)
- **tfsec**: Terraform-specific security scanner
- **Checkov**: Multi-language IaC scanner
- **terraform-compliance**: BDD-style compliance testing
- **Terrascan**: Policy-as-code for IaC

## References

- [AWS Security Best Practices](https://docs.aws.amazon.com/security/)
- [Trivy Documentation](https://trivy.dev/)
- [CIS AWS Foundations Benchmark](https://www.cisecurity.org/benchmark/amazon_web_services)
- [OWASP IaC Security Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Infrastructure_as_Code_Security_Cheat_Sheet.html)

## Next Steps

1. Scan both configurations and compare results
2. Try to fix issues in the insecure configuration
3. Create your own test cases for other vulnerabilities
4. Integrate Trivy into a CI/CD pipeline
5. Explore other security scanning tools

Remember: Security is not a one-time task but an ongoing process!
