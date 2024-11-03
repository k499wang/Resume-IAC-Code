resource "aws_dynamodb_table" "cloud_resume_database" {
  name         = "Cloud-Resume-Database2"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "id"
    type = "S" # String type for the id
  }

  hash_key = "id"

  tags = {
    Name = "Cloud-Resume-Database"
  }
}


resource "aws_dynamodb_table_item" "initial_item" {
  table_name = aws_dynamodb_table.cloud_resume_database.name
  hash_key   = "id"

  # Define the initial item with the specified structure
  item = jsonencode({
    id  = { S = "2" }
    ips = { 
      L = [
        { S = "129.97.124.109" },
        { S = "UNKNOWN_IP" },
        { S = "" },
        { NULL = true }
      ]
    }
  })
}

# Outputs
output "dynamodb_table_name" {
  value = aws_dynamodb_table.cloud_resume_database.name
}