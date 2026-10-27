output "knowledge_base_id" {
  value = genesyscloud_knowledge_knowledgebase.kb.id
}

output "virtual_agent_id" {
  value = genesyscloud_agentic_virtual_agent.assistant.id
}

output "program_id" {
  value = genesyscloud_speechandtextanalytics_program.main.id
}
