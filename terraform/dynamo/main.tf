resource "aws_dynamodb_table" "participant_table" {
  name         = "participantDynamoDBTable"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "wheel_id"
  range_key    = "id"

  attribute {
    name = "id"
    type = "S"
  }

  attribute {
    name = "wheel_id"
    type = "S"
  }
}

resource "aws_dynamodb_table" "wheel_table" {
  name         = "wheelDynamoDBTable"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }
}