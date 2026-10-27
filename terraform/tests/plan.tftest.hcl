# Offline plan test. The Genesys provider is MOCKED, so this needs no org, no OAuth client and no network.
# It proves that the design in locals.tf expands into resources without type errors, bad references or
# empty for_each maps. It does NOT prove that Genesys will accept the objects. Only a real apply proves that.
# Run:  cd terraform && tofu init -backend=false && tofu test

mock_provider "genesyscloud" {}

run "minimal" {
  command = plan

  variables {
    enable_ai      = false
    enable_quality = false
    enable_digital = false
  }

  assert {
    condition     = length(output.queue_ids) >= 8
    error_message = "Expected the design to produce at least 8 queues."
  }

  assert {
    condition     = output.surge_group_enabled == false
    error_message = "The surge switch must be OFF by default."
  }

  assert {
    condition     = output.sign_in_hardening_applied == false
    error_message = "Sign-in hardening must be OFF by default. It can lock everyone out."
  }
}

run "full" {
  command = plan

  variables {
    enable_ai      = true
    enable_quality = true
    enable_digital = true
  }
}

run "surge_switch_on" {
  command = plan

  variables {
    enable_ai          = true
    enable_quality     = true
    enable_digital     = true
    surge_mode_enabled = true
  }

  assert {
    condition     = output.surge_group_enabled == true
    error_message = "Setting surge_mode_enabled = true must switch the emergency group on."
  }
}

run "hardened" {
  command = plan

  variables {
    enable_ai                 = true
    enable_quality            = true
    enable_digital            = true
    enable_security_hardening = true
  }

  assert {
    condition     = output.sign_in_hardening_applied == true
    error_message = "enable_security_hardening = true must apply the sign-in settings."
  }
}
