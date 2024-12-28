module "knowledge_base" {
  source = "../.."

  name            = "knowledge-base"
  embedding_model = "amazon.titan-embed-text-v2:0"

  storage_type = "OPENSEARCH_SERVERLESS"
  opensearch_serverless_config = {
    collection_arn    = aws_opensearchserverless_collection.knowledge_base.arn
    vector_index_name = opensearch_index.knowledge_base.name
    field_mapping = {
      vector_field   = "vector"
      metadata_field = "metadata"
      text_field     = "text"
    }
  }

  data_source_configurations = {
    "source1" = {
      bucket                   = aws_s3_bucket.data_sources.bucket
      bucket_paths             = ["source1"]
      chunking_strategy        = "FIXED_SIZE"
      fixed_max_tokens         = 300
      fixed_overlap_percentage = 10
    }
  }
}
