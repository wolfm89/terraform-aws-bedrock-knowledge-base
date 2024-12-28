# Amazon Bedrock Knowledge Base Terraform module

Terraform modules which creates Amazon Bedrock Knowledge Base resources on AWS.
The module follows the same structure as the [Terraform AWS community modules](https://github.com/terraform-aws-modules).

## Usage

```hcl

```

## Examples

- [](./examples//README.md):

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.9 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.82 |
| <a name="requirement_time"></a> [time](#requirement\_time) | ~> 0.12 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.82 |
| <a name="provider_time"></a> [time](#provider\_time) | ~> 0.12 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_bedrockagent_data_source.data_source](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/bedrockagent_data_source) | resource |
| [aws_bedrockagent_knowledge_base.kb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/bedrockagent_knowledge_base) | resource |
| [aws_iam_policy.kb_policy_base](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.kb_policy_data_source](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.kb_policy_storage](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.kb_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.kb_policy_attachment_base](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.kb_policy_attachment_data_source](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.kb_policy_attachment_storage](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_opensearchserverless_access_policy.kb_opensearch_access_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/opensearchserverless_access_policy) | resource |
| [time_sleep.wait_for_policy_attachment](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.kb_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.kb_policy_document_base](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.kb_policy_document_data_source](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.kb_policy_document_storage](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_opensearchserverless_collection.kb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/opensearchserverless_collection) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_data_source_configurations"></a> [data\_source\_configurations](#input\_data\_source\_configurations) | Configuration for the data source | <pre>map(object({<br/>    bucket                                   = string<br/>    bucket_paths                             = list(string)<br/>    chunking_strategy                        = optional(string, "NONE")<br/>    fixed_max_tokens                         = optional(number, null)<br/>    fixed_overlap_percentage                 = optional(number, null)<br/>    hierarchical_level_parent_max_tokens     = optional(number, null)<br/>    hierarchical_level_child_max_tokens      = optional(number, null)<br/>    hierarchical_overlap_tokens              = optional(number, null)<br/>    semantic_breakpoint_percentile_threshold = optional(number, null)<br/>    semantic_buffer_size                     = optional(number, null)<br/>    semantic_max_tokens                      = optional(number, null)<br/>    parsing_model_arn                        = optional(string, null)<br/>    parsing_prompt_string                    = optional(string, null)<br/>  }))</pre> | n/a | yes |
| <a name="input_embedding_model"></a> [embedding\_model](#input\_embedding\_model) | Name of the embedding model | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name of the knowledge base | `string` | n/a | yes |
| <a name="input_opensearch_serverless_config"></a> [opensearch\_serverless\_config](#input\_opensearch\_serverless\_config) | Configuration for OpenSearch Serverless | <pre>object({<br/>    collection_arn    = string<br/>    vector_index_name = string<br/>    field_mapping = object({<br/>      vector_field   = string<br/>      text_field     = string<br/>      metadata_field = string<br/>    })<br/>  })</pre> | `null` | no |
| <a name="input_pinecone_config"></a> [pinecone\_config](#input\_pinecone\_config) | Configuration for Pinecone | <pre>object({<br/>    connection_string      = string<br/>    credentials_secret_arn = string<br/>    field_mapping = object({<br/>      text_field     = string<br/>      metadata_field = string<br/>    })<br/>    namespace = optional(string, null)<br/>  })</pre> | `null` | no |
| <a name="input_rds_config"></a> [rds\_config](#input\_rds\_config) | Configuration for RDS | <pre>object({<br/>    aurora_cluster_arn     = string<br/>    database_name          = string<br/>    table_name             = string<br/>    credentials_secret_arn = string<br/>    field_mapping = optional(object({<br/>      vector_field      = string<br/>      text_field        = string<br/>      metadata_field    = string<br/>      primary_key_field = string<br/>      }), {<br/>      vector_field      = "embedding"<br/>      text_field        = "chunks"<br/>      metadata_field    = "metadata"<br/>      primary_key_field = "id"<br/>    })<br/>  })</pre> | `null` | no |
| <a name="input_redis_enterprise_cloud_config"></a> [redis\_enterprise\_cloud\_config](#input\_redis\_enterprise\_cloud\_config) | Configuration for Redis Enterprise Cloud | <pre>object({<br/>    endpoint               = string<br/>    vector_index_name      = string<br/>    credentials_secret_arn = string<br/>    field_mapping = object({<br/>      vector_field   = string<br/>      text_field     = string<br/>      metadata_field = string<br/>    })<br/>  })</pre> | `null` | no |
| <a name="input_storage_type"></a> [storage\_type](#input\_storage\_type) | Type of the storage configuration | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_data_source_ids"></a> [data\_source\_ids](#output\_data\_source\_ids) | Map of data source name to ID. |
| <a name="output_knowledge_base_id"></a> [knowledge\_base\_id](#output\_knowledge\_base\_id) | The ID of the knowledge base. |
<!-- END_TF_DOCS -->
