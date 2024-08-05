provider "aws" {
  region = "ap-northeast-2"
}

# S3 버킷 생성
resource "aws_s3_bucket" "terraform_state" {
  bucket = "your-terraform-state-bucket"

  tags = {
    Name = "Terraform State Bucket"
  }
}

# S3 버킷 버전 관리 설정
resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.terraform_state.bucket

  versioning_configuration {
    status = "Enabled"
  }
}

# S3 버킷 암호화 설정
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# DynamoDB 테이블 생성
resource "aws_dynamodb_table" "terraform_lock" {
  name         = "terraform-lock-table"
  billing_mode = "PROVISIONED"
  read_capacity = 5
  write_capacity = 5
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "Terraform Lock Table"
  }
}

# 백엔드 설정
terraform {
  backend "s3" {
    bucket         = aws_s3_bucket.terraform_state.bucket
    key            = "path/to/your/terraform.tfstate"  # tfstate 파일 경로
    region         = "ap-northeast-2"
    dynamodb_table = aws_dynamodb_table.terraform_lock.name
    encrypt        = true
  }
}
