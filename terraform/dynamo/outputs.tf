output participant_table {
  value = aws_dynamodb_table.participant_table.id
}

output wheel_table {
  value = aws_dynamodb_table.wheel_table.id
}