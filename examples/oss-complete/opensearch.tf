data "aws_caller_identity" "current" {}

# OpenSearch collection
resource "aws_opensearchserverless_collection" "knowledge_base" {
  name             = "knowledge-base"
  standby_replicas = "DISABLED"
  type             = "VECTORSEARCH"

  depends_on = [
    aws_opensearchserverless_security_policy.knowledge_base_policy,
    aws_opensearchserverless_security_policy.network_policy,
    aws_opensearchserverless_access_policy.knowledge_base_access_policy
  ]
}

resource "time_sleep" "wait_for_collection" {
  depends_on = [aws_opensearchserverless_collection.knowledge_base]

  create_duration = "30s"
}

# OpenSearch security policy
resource "aws_opensearchserverless_security_policy" "knowledge_base_policy" {
  name        = "knowledge-base-policy"
  description = "Security policy for knowledge base collection"
  type        = "encryption"
  policy = jsonencode({
    "Rules" = [
      {
        "Resource" = [
          "collection/knowledge-base"
        ],
        "ResourceType" = "collection"
      }
    ],
    "AWSOwnedKey" = true
  })
}

resource "aws_opensearchserverless_security_policy" "network_policy" {
  name        = "network-policy"
  type        = "network"
  description = "Public access"
  policy = jsonencode([
    {
      Description = "Public access to collection and Dashboards endpoint for knowledge base collection",
      Rules = [
        {
          ResourceType = "collection",
          Resource = [
            "collection/knowledge-base"
          ]
        },
        {
          ResourceType = "dashboard",
          Resource = [
            "collection/knowledge-base"
          ]
        }
      ],
      AllowFromPublic = true
    }
  ])
}

resource "aws_opensearchserverless_access_policy" "knowledge_base_access_policy" {
  name        = "knowledge-base-access-policy"
  type        = "data"
  description = "Access policy for knowledge base collection"
  policy = jsonencode([
    {
      Rules = [
        {
          ResourceType = "index",
          Resource = [
            "index/knowledge-base/*"
          ],
          Permission = [
            "aoss:*"
          ]
        },
        {
          ResourceType = "collection",
          Resource = [
            "collection/knowledge-base"
          ],
          Permission = [
            "aoss:*"
          ]
        }
      ],
      Principal = [
        data.aws_caller_identity.current.arn
      ]
    }
  ])
}

# OpenSearch index
resource "opensearch_index" "knowledge_base" {
  name                           = "knowledge-base"
  number_of_shards               = "2"
  number_of_replicas             = "0"
  index_knn                      = true
  index_knn_algo_param_ef_search = "512"
  mappings = jsonencode({
    "properties" = {
      "vector" = {
        "type"      = "knn_vector",
        "dimension" = 1024,
        "method" = {
          "name"       = "hnsw",
          "engine"     = "faiss",
          "space_type" = "l2"
        },
      },
      "metadata" = {
        "type"  = "text",
        "index" = false
      },
      "text" = {
        "type"  = "text",
        "index" = true
      }
    }
  })
  force_destroy = true
  depends_on = [
    aws_opensearchserverless_collection.knowledge_base,
    time_sleep.wait_for_collection
  ]
  lifecycle {
    ignore_changes = [mappings]
  }
}
