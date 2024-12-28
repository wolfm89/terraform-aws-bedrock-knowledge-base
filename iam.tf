locals {
  collection_id = split("/", provider::aws::arn_parse(var.opensearch_serverless_config.collection_arn)["resource"])[1]
}

data "aws_opensearchserverless_collection" "kb" {
  id = local.collection_id
}

resource "aws_iam_role" "kb_role" {
  name = "kb-${var.name}-role"

  assume_role_policy = data.aws_iam_policy_document.kb_assume_role.json
}

resource "time_sleep" "wait_for_policy_attachment" {
  depends_on = [
    aws_iam_role_policy_attachment.kb_policy_attachment_base,
    aws_iam_role_policy_attachment.kb_policy_attachment_storage,
    aws_iam_role_policy_attachment.kb_policy_attachment_data_source,
    aws_opensearchserverless_access_policy.kb_opensearch_access_policy
  ]

  create_duration = "10s"
}

data "aws_iam_policy_document" "kb_assume_role" {
  version = "2012-10-17"

  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["bedrock.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }

    condition {
      test     = "ArnLike"
      variable = "AWS:SourceArn"
      values   = ["arn:aws:bedrock:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:knowledge-base/*"]
    }
  }
}

data "aws_iam_policy_document" "kb_policy_document_base" {
  version = "2012-10-17"

  statement {
    sid    = "ListFoundationModelsStatementID"
    effect = "Allow"
    actions = [
      "bedrock:ListFoundationModels",
      "bedrock:ListCustomModels"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "InvokeModelStatementID"
    effect = "Allow"
    actions = [
      "bedrock:InvokeModel"
    ]
    resources = ["arn:aws:bedrock:${data.aws_region.current.name}::foundation-model/${var.embedding_model}"
    ]
  }
}

data "aws_iam_policy_document" "kb_policy_document_storage" {
  version = "2012-10-17"

  dynamic "statement" {
    for_each = var.storage_type == "RDS" ? [1] : []
    content {
      sid    = "RdsDescribeStatementID"
      effect = "Allow"
      actions = [
        "rds:DescribeDBClusters"
      ]
      resources = [var.rds_config.aurora_cluster_arn]
    }
  }

  dynamic "statement" {
    for_each = var.storage_type == "RDS" ? [1] : []
    content {
      sid    = "DataAPIStatementID"
      effect = "Allow"
      actions = [
        "rds-data:BatchExecuteStatement",
        "rds-data:ExecuteStatement"
      ]
      resources = [var.rds_config.aurora_cluster_arn]
    }
  }

  dynamic "statement" {
    for_each = var.storage_type == "RDS" ? [1] : []
    content {
      sid    = "SecretsManagerStatementID"
      effect = "Allow"
      actions = [
        "secretsmanager:GetSecretValue"
      ]
      resources = [var.rds_config.credentials_secret_arn]
    }
  }

  dynamic "statement" {
    for_each = var.storage_type == "REDIS_ENTERPRISE_CLOUD" ? [1] : []
    content {
      sid    = "RedisEnterpriseCloudAssociateThirdPartyKnowledgeBase"
      effect = "Allow"
      actions = [
        "bedrock:AssociateThirdPartyKnowledgeBase"
      ]
      resources = ["*"]
      condition {
        test     = "StringEquals"
        variable = "bedrock:ThirdPartyKnowledgeBaseCredentialsSecretArn"
        values   = [var.redis_enterprise_cloud_config.credentials_secret_arn]
      }
    }
  }

  dynamic "statement" {
    for_each = var.storage_type == "PINECONE" ? [1] : []
    content {
      sid    = "PineconeAssociateThirdPartyKnowledgeBase"
      effect = "Allow"
      actions = [
        "bedrock:AssociateThirdPartyKnowledgeBase"
      ]
      resources = ["*"]
      condition {
        test     = "StringEquals"
        variable = "bedrock:ThirdPartyKnowledgeBaseCredentialsSecretArn"
        values   = [var.pinecone_config.credentials_secret_arn]
      }
    }
  }

  dynamic "statement" {
    for_each = var.storage_type == "OPENSEARCH_SERVERLESS" ? [1] : []
    content {
      sid    = "OpenSearchServerlessAPIAccessAllStatement"
      effect = "Allow"
      actions = [
        "aoss:APIAccessAll"
      ]
      resources = [
        var.opensearch_serverless_config.collection_arn
      ]
    }
  }
}

data "aws_iam_policy_document" "kb_policy_document_data_source" {
  version = "2012-10-17"

  dynamic "statement" {
    for_each = var.data_source_configurations
    iterator = ds_config
    content {
      effect = "Allow"
      actions = [
        "s3:GetObject"
      ]
      resources = flatten([
        for path in ds_config.value.bucket_paths : [
          "arn:aws:s3:::${ds_config.value.bucket}/${path}",
          "arn:aws:s3:::${ds_config.value.bucket}/${path}/*"
        ]
      ])
      condition {
        test     = "StringEquals"
        variable = "aws:PrincipalAccount"
        values   = [data.aws_caller_identity.current.account_id]
      }
    }
  }

  dynamic "statement" {
    for_each = var.data_source_configurations
    iterator = ds_config
    content {
      effect = "Allow"
      actions = [
        "s3:ListBucket"
      ]
      resources = [
        "arn:aws:s3:::${ds_config.value.bucket}"
      ]
      condition {
        test     = "StringEquals"
        variable = "aws:PrincipalAccount"
        values   = [data.aws_caller_identity.current.account_id]
      }
    }
  }
}

resource "aws_iam_policy" "kb_policy_base" {
  name        = "kb-${var.name}-policy-base"
  description = "Base policy for knowledge base role"

  policy = data.aws_iam_policy_document.kb_policy_document_base.json
}

resource "aws_iam_policy" "kb_policy_storage" {
  name        = "kb-${var.name}-policy-storage"
  description = "Storage policy for knowledge base role"

  policy = data.aws_iam_policy_document.kb_policy_document_storage.json
}

resource "aws_iam_policy" "kb_policy_data_source" {
  name        = "kb-${var.name}-policy-data-source"
  description = "Data source policy for knowledge base role"

  policy = data.aws_iam_policy_document.kb_policy_document_data_source.json
}

resource "aws_iam_role_policy_attachment" "kb_policy_attachment_base" {
  role       = aws_iam_role.kb_role.name
  policy_arn = aws_iam_policy.kb_policy_base.arn
}

resource "aws_iam_role_policy_attachment" "kb_policy_attachment_storage" {
  role       = aws_iam_role.kb_role.name
  policy_arn = aws_iam_policy.kb_policy_storage.arn
}

resource "aws_iam_role_policy_attachment" "kb_policy_attachment_data_source" {
  role       = aws_iam_role.kb_role.name
  policy_arn = aws_iam_policy.kb_policy_data_source.arn
}

resource "aws_opensearchserverless_access_policy" "kb_opensearch_access_policy" {
  count       = var.storage_type == "OPENSEARCH_SERVERLESS" ? 1 : 0
  name        = "kb-${var.name}-access-policy"
  type        = "data"
  description = "Access policy for knowledge base OpenSearch collection"
  policy = jsonencode([
    {
      Rules = [
        {
          ResourceType = "index",
          Resource = [
            "index/${data.aws_opensearchserverless_collection.kb.name}/*"
          ],
          Permission = [
            "aoss:*"
          ]
        },
        {
          ResourceType = "collection",
          Resource = [
            "collection/${data.aws_opensearchserverless_collection.kb.name}"
          ],
          Permission = [
            "aoss:*"
          ]
        }
      ],
      Principal = [
        aws_iam_role.kb_role.arn
      ]
    }
  ])
}
