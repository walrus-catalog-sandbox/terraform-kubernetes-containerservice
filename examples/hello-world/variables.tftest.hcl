run "valid_variable" {
  command = plan

  assert {
    condition     = module.this.walrus_project_name == "project_name"
    error_message = "Unexpected output project name"
  }
}
