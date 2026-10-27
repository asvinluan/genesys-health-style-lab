# Full build PLUS organisation-wide sign-in hardening. LAB ORG ONLY.
# Read terraform/modules/security/main.tf first. A wrong IP list or MFA setting can lock every user out,
# including you. Keep a second admin session open in another browser while you apply.
enable_ai                 = true
enable_quality            = true
enable_digital            = true
web_allowed_domains       = ["www.health-style-lab.example.invalid"]
enable_security_hardening = true
# signin_ip_allowlist = ["203.0.113.0/24"]   # documentation range. Replace with your own network.
