# Figures Directory

## Screenshots for Academic Report

Place your screenshots in this directory with the following naming convention:

### Required Screenshots

1. **`deployed-website.png`** - Screenshot of the deployed Next.js website

   - URL: http://practical6-deployment-dev.s3-website.localhost.localstack.cloud:4566
   - Should show the blue/purple gradient page with "Practical 6" title

2. **`terraform-apply.png`** - Screenshot of successful Terraform apply

   - Shows: "Apply complete! Resources: 11 added, 0 changed, 0 destroyed"
   - Shows: All Terraform outputs

3. **`trivy-scan-secure.png`** - Trivy scan results for secure configuration

   - Command: `make scan`
   - Shows: CRITICAL: 0, HIGH: 3 (acceptable findings)

4. **`trivy-scan-insecure.png`** - Trivy scan results for fixed insecure configuration

   - Command: `make scan-insecure`
   - Shows: CRITICAL: 0, HIGH: 3 (KMS warnings)

5. **`security-comparison.png`** - Security comparison report
   - Command: `make compare-security`
   - Shows: Before/after vulnerability counts

## File Format

- **Format**: PNG or JPEG
- **Resolution**: Minimum 1280x720 for readability
- **Naming**: Use lowercase with hyphens (kebab-case)

## How to Take Screenshots

### macOS

- `Cmd + Shift + 4` - Select area to capture
- `Cmd + Shift + 3` - Capture entire screen

### Windows

- `Windows + Shift + S` - Snipping tool
- `PrtScn` - Print screen

### Linux

- `gnome-screenshot -a` - Select area
- `scrot -s` - Select area (requires scrot)

## Viewing in README

The screenshots are referenced in the main README.md using relative paths:

```markdown
![Deployed Website](./figures/deployed-website.png)
```

Make sure your screenshot files are named exactly as referenced in the README for proper display.
