# Amazon Bedrock Knowledge Base with Amazon OpenSearch Service as vector database

The configuration in this directory creates an Amazon Bedrock Knowledge Base with Amazon OpenSearch Service as vector database.

## Usage

Make sure you have your AWS credentials [properly configured](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html).

Create a file named `config.s3.tfbackend` with the following content:

```hcl
bucket = "<your-terraform-state-s3-bucket>"
key    = "examples/oss-complete.tfstate"
region = "<your-aws-region>"
```

This will be used to configure the S3 backend for Terraform.

Create a file named `terraform.tfvars` with the following content (replace the values with your own):

```hcl
creator = "my.email@email.com"
```

To run this example you need to execute:

```bash
$ terraform init -backend-config="config.s3.tfbackend"
$ terraform plan
$ terraform apply
```

Note that this example may create resources which can cost money. Run `terraform destroy` when you don't need these resources.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.9 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.82 |
| <a name="requirement_opensearch"></a> [opensearch](#requirement\_opensearch) | ~> 2.3 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.6 |
| <a name="requirement_time"></a> [time](#requirement\_time) | ~> 0.12 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.82 |
| <a name="provider_opensearch"></a> [opensearch](#provider\_opensearch) | ~> 2.3 |
| <a name="provider_random"></a> [random](#provider\_random) | ~> 3.6 |
| <a name="provider_time"></a> [time](#provider\_time) | ~> 0.12 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_knowledge_base"></a> [knowledge\_base](#module\_knowledge\_base) | ../.. | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_opensearchserverless_access_policy.knowledge_base_access_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/opensearchserverless_access_policy) | resource |
| [aws_opensearchserverless_collection.knowledge_base](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/opensearchserverless_collection) | resource |
| [aws_opensearchserverless_security_policy.knowledge_base_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/opensearchserverless_security_policy) | resource |
| [aws_opensearchserverless_security_policy.network_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/opensearchserverless_security_policy) | resource |
| [aws_s3_bucket.data_sources](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_object.data_source](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [opensearch_index.knowledge_base](https://registry.terraform.io/providers/opensearch-project/opensearch/latest/docs/resources/index) | resource |
| [random_id.suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [time_sleep.wait_for_collection](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_creator"></a> [creator](#input\_creator) | Creator of the resources. Used for resource tagging | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
