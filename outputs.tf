output "knowledge_base_id" {
  description = "The ID of the knowledge base."
  value       = aws_bedrockagent_knowledge_base.kb.id
}

output "data_source_ids" {
  description = "Map of data source name to ID."
  value       = { for k, v in aws_bedrockagent_data_source.data_source : k => v.data_source_id }
}
