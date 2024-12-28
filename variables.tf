variable "name" {
  description = "Name of the knowledge base"
  type        = string
}

variable "embedding_model" {
  description = "Name of the embedding model"
  type        = string
}

variable "storage_type" {
  description = "Type of the storage configuration"
  type        = string

  validation {
    condition     = var.storage_type == "OPENSEARCH_SERVERLESS" || var.storage_type == "PINECONE" || var.storage_type == "REDIS_ENTERPRISE_CLOUD" || var.storage_type == "RDS"
    error_message = "storage_type must be one of 'OPENSEARCH_SERVERLESS', 'PINECONE', 'REDIS_ENTERPRISE_CLOUD', or 'RDS'."
  }
}

variable "opensearch_serverless_config" {
  description = "Configuration for OpenSearch Serverless"
  type = object({
    collection_arn    = string
    vector_index_name = string
    field_mapping = object({
      vector_field   = string
      text_field     = string
      metadata_field = string
    })
  })
  default = null

  validation {
    condition     = var.storage_type == "OPENSEARCH_SERVERLESS" ? var.opensearch_serverless_config != null : true
    error_message = "opensearch_serverless_config must not be null when storage_type is set to OPENSEARCH_SERVERLESS."
  }
}

variable "pinecone_config" {
  description = "Configuration for Pinecone"
  type = object({
    connection_string      = string
    credentials_secret_arn = string
    field_mapping = object({
      text_field     = string
      metadata_field = string
    })
    namespace = optional(string, null)
  })
  default = null

  validation {
    condition     = var.storage_type == "PINECONE" ? var.pinecone_config != null : true
    error_message = "pinecone_config must not be null when storage_type is set to PINECONE."
  }
}

variable "redis_enterprise_cloud_config" {
  description = "Configuration for Redis Enterprise Cloud"
  type = object({
    endpoint               = string
    vector_index_name      = string
    credentials_secret_arn = string
    field_mapping = object({
      vector_field   = string
      text_field     = string
      metadata_field = string
    })
  })
  default = null

  validation {
    condition     = var.storage_type == "REDIS_ENTERPRISE_CLOUD" ? var.redis_enterprise_cloud_config != null : true
    error_message = "redis_enterprise_cloud_config must not be null when storage_type is set to REDIS_ENTERPRISE_CLOUD."
  }
}

variable "rds_config" {
  description = "Configuration for RDS"
  type = object({
    aurora_cluster_arn     = string
    database_name          = string
    table_name             = string
    credentials_secret_arn = string
    field_mapping = optional(object({
      vector_field      = string
      text_field        = string
      metadata_field    = string
      primary_key_field = string
      }), {
      vector_field      = "embedding"
      text_field        = "chunks"
      metadata_field    = "metadata"
      primary_key_field = "id"
    })
  })
  default = null

  validation {
    condition     = var.storage_type == "RDS" ? var.rds_config != null : true
    error_message = "rds_config must not be null when storage_type is set to RDS."
  }
}
variable "data_source_configurations" {
  description = "Configuration for the data source"
  type = map(object({
    bucket                                   = string
    bucket_paths                             = list(string)
    chunking_strategy                        = optional(string, "NONE")
    fixed_max_tokens                         = optional(number, null)
    fixed_overlap_percentage                 = optional(number, null)
    hierarchical_level_parent_max_tokens     = optional(number, null)
    hierarchical_level_child_max_tokens      = optional(number, null)
    hierarchical_overlap_tokens              = optional(number, null)
    semantic_breakpoint_percentile_threshold = optional(number, null)
    semantic_buffer_size                     = optional(number, null)
    semantic_max_tokens                      = optional(number, null)
    parsing_model_arn                        = optional(string, null)
    parsing_prompt_string                    = optional(string, null)
  }))

  validation {
    condition     = length(var.data_source_configurations) > 0
    error_message = "data_source_configurations must contain at least one element."
  }

  validation {
    condition     = alltrue([for config in var.data_source_configurations : contains(["FIXED_SIZE", "HIERARCHICAL", "SEMANTIC", "NONE"], config.chunking_strategy)])
    error_message = "chunking_strategy must be one of 'FIXED_SIZE', 'HIERARCHICAL', 'SEMANTIC', or 'NONE'."
  }

  validation {
    condition     = alltrue([for config in var.data_source_configurations : config.chunking_strategy == "FIXED_SIZE" ? config.fixed_max_tokens > 0 : true])
    error_message = "fixed_max_tokens must be greater than 0 when chunking_strategy is 'FIXED_SIZE'."
  }

  validation {
    condition     = alltrue([for config in var.data_source_configurations : config.chunking_strategy == "FIXED_SIZE" ? config.fixed_overlap_percentage >= 0 && config.fixed_overlap_percentage <= 100 : true])
    error_message = "fixed_overlap_percentage must be between 0 and 100 when chunking_strategy is 'FIXED_SIZE'."
  }

  validation {
    condition     = alltrue([for config in var.data_source_configurations : config.chunking_strategy == "HIERARCHICAL" ? config.hierarchical_level_parent_max_tokens > 0 : true])
    error_message = "hierarchical_level_parent_max_tokens must be greater than 0 when chunking_strategy is 'HIERARCHICAL'."
  }

  validation {
    condition     = alltrue([for config in var.data_source_configurations : config.chunking_strategy == "HIERARCHICAL" ? config.hierarchical_level_child_max_tokens > 0 : true])
    error_message = "hierarchical_level_child_max_tokens must be greater than 0 when chunking_strategy is 'HIERARCHICAL'."
  }

  validation {
    condition     = alltrue([for config in var.data_source_configurations : config.chunking_strategy == "HIERARCHICAL" ? config.hierarchical_overlap_tokens > 0 : true])
    error_message = "hierarchical_overlap_tokens must be greater than 0 when chunking_strategy is 'HIERARCHICAL'."
  }

  validation {
    condition     = alltrue([for config in var.data_source_configurations : config.chunking_strategy == "SEMANTIC" ? config.semantic_breakpoint_percentile_threshold > 0 : true])
    error_message = "semantic_breakpoint_percentile_threshold must be greater than 0 when chunking_strategy is 'SEMANTIC'."
  }

  validation {
    condition     = alltrue([for config in var.data_source_configurations : config.chunking_strategy == "SEMANTIC" ? config.semantic_buffer_size > 0 : true])
    error_message = "semantic_buffer_size must be greater than 0 when chunking_strategy is 'SEMANTIC'."
  }

  validation {
    condition     = alltrue([for config in var.data_source_configurations : config.chunking_strategy == "SEMANTIC" ? config.semantic_max_tokens > 0 : true])
    error_message = "semantic_max_tokens must be greater than 0 when chunking_strategy is 'SEMANTIC'."
  }

  validation {
    condition     = alltrue([for config in var.data_source_configurations : config.parsing_model_arn != null ? config.parsing_prompt_string != null : true])
    error_message = "parsing_model_arn and parsing_prompt_string must both be set when parsing_model_arn is set."
  }
}
