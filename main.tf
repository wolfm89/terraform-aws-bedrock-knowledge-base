data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "aws_bedrockagent_data_source" "data_source" {
  for_each = var.data_source_configurations
  lifecycle {
    replace_triggered_by = [aws_bedrockagent_knowledge_base.kb.id]
  }

  knowledge_base_id = aws_bedrockagent_knowledge_base.kb.id
  name              = "${var.name}-ds-${each.key}"
  data_source_configuration {
    type = "S3"
    s3_configuration {
      bucket_arn         = "arn:aws:s3:::${each.value.bucket}"
      inclusion_prefixes = each.value.bucket_paths
    }
  }
  vector_ingestion_configuration {
    chunking_configuration {
      chunking_strategy = each.value.chunking_strategy

      dynamic "fixed_size_chunking_configuration" {
        for_each = each.value.chunking_strategy == "FIXED_SIZE" ? [1] : []
        content {
          max_tokens         = each.value.fixed_max_tokens
          overlap_percentage = each.value.fixed_overlap_percentage
        }
      }

      dynamic "hierarchical_chunking_configuration" {
        for_each = each.value.chunking_strategy == "HIERARCHICAL" ? [1] : []
        content {
          level_configuration {
            max_tokens = each.value.hierarchical_level_parent_max_tokens
          }
          level_configuration {
            max_tokens = each.value.hierarchical_level_child_max_tokens
          }
          overlap_tokens = each.value.hierarchical_overlap_tokens
        }
      }

      dynamic "semantic_chunking_configuration" {
        for_each = each.value.chunking_strategy == "SEMANTIC" ? [1] : []
        content {
          breakpoint_percentile_threshold = each.value.semantic_breakpoint_percentile_threshold
          buffer_size                     = each.value.semantic_buffer_size
          max_token                       = each.value.semantic_max_tokens
        }
      }
    }

    dynamic "parsing_configuration" {
      for_each = each.value.parsing_model_arn != null ? [1] : []
      content {
        parsing_strategy = "BEDROCK_FOUNDATION_MODEL"
        bedrock_foundation_model_configuration {
          model_arn = each.value.parsing_model_arn
          parsing_prompt {
            parsing_prompt_string = each.value.parsing_prompt_string
          }
        }
      }
    }
  }
}

resource "aws_bedrockagent_knowledge_base" "kb" {
  depends_on = [
    time_sleep.wait_for_policy_attachment,
    aws_opensearchserverless_access_policy.kb_opensearch_access_policy
  ]
  name     = "kb-${var.name}"
  role_arn = aws_iam_role.kb_role.arn
  knowledge_base_configuration {
    vector_knowledge_base_configuration {
      embedding_model_arn = "arn:aws:bedrock:${data.aws_region.current.name}::foundation-model/${var.embedding_model}"
    }
    type = "VECTOR"
  }
  storage_configuration {
    type = var.storage_type

    dynamic "opensearch_serverless_configuration" {
      for_each = var.storage_type == "OPENSEARCH_SERVERLESS" ? [1] : []
      content {
        collection_arn = var.opensearch_serverless_config.collection_arn
        field_mapping {
          metadata_field = var.opensearch_serverless_config.field_mapping.metadata_field
          text_field     = var.opensearch_serverless_config.field_mapping.text_field
          vector_field   = var.opensearch_serverless_config.field_mapping.vector_field
        }
        vector_index_name = var.opensearch_serverless_config.vector_index_name
      }
    }

    dynamic "pinecone_configuration" {
      for_each = var.storage_type == "PINECONE" ? [1] : []
      content {
        connection_string      = var.pinecone_config.connection_string
        credentials_secret_arn = var.pinecone_config.credentials_secret_arn
        field_mapping {
          metadata_field = var.pinecone_config.field_mapping.metadata_field
          text_field     = var.pinecone_config.field_mapping.text_field
        }
        namespace = var.pinecone_config.namespace
      }
    }

    dynamic "redis_enterprise_cloud_configuration" {
      for_each = var.storage_type == "REDIS_ENTERPRISE_CLOUD" ? [1] : []
      content {
        credentials_secret_arn = var.redis_enterprise_cloud_config.credentials_secret_arn
        endpoint               = var.redis_enterprise_cloud_config.endpoint
        field_mapping {
          metadata_field = var.redis_enterprise_cloud_config.field_mapping.metadata_field
          text_field     = var.redis_enterprise_cloud_config.field_mapping.text_field
          vector_field   = var.redis_enterprise_cloud_config.field_mapping.vector_field
        }
        vector_index_name = var.redis_enterprise_cloud_config.vector_index_name
      }
    }

    dynamic "rds_configuration" {
      for_each = var.storage_type == "RDS" ? [1] : []
      content {
        resource_arn           = var.rds_config.aurora_cluster_arn
        credentials_secret_arn = var.rds_config.db_user_secret_arn
        database_name          = var.rds_config.database_name
        table_name             = var.rds_config.table_name
        field_mapping {
          vector_field      = var.rds_config.field_mapping.vector_field
          text_field        = var.rds_config.field_mapping.text_field
          metadata_field    = var.rds_config.field_mapping.metadata_field
          primary_key_field = var.rds_config.field_mapping.primary_key_field
        }
      }
    }
  }
}
