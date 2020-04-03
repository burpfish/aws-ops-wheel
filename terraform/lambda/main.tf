locals {
  zip_filename = "${path.root}/../build/lambda.zip"

  memory_size = 128
  runtime     = "python3.6"
  timeout     = 3

  env = {
    // We have disabled Cognito - these values are not used (tehey are returned by an endpoint that the client no longer calls)
    APP_CLIENT_ID = "N/A"
    USER_POOL_ID  = "N/A"

    PARTICIPANT_TABLE = var.participant_table
    WHEEL_TABLE       = var.wheel_table
  }

  lambda_config = [
    {
      name        = "ConfigLambda"
      description = "Return configuration details"
      handler     = "base.config"
    },
    {
      name        = "CreateParticipantLambda"
      description = "Create a participant"
      handler     = "wheel_participant.create_participant"
    },
    {
      name        = "CreateWheelLambda"
      description = "Create a wheel. Requires a name"
      handler     = "wheel.create_wheel"
    },
    {
      name        = "DeleteParticipantLambda"
      description = "Deletes the participant from the wheel and redistributes wheel"
      handler     = "wheel_participant.delete_participant"
    },
    {
      name        = "DeleteWheelLambda"
      description = "Deletes the wheel and all of its participants"
      handler     = "wheel.delete_wheel"
    },
    {
      name        = "GetWheelLambda"
      description = "Returns the wheel object corresponding to the given wheel_id"
      handler     = "wheel.get_wheel"
    },
    {
      name        = "ListParticipantsLambda"
      description = "Gets the participants for the specified wheel_id"
      handler     = "wheel_participant.list_participants"
    },
    {
      name        = "ListWheelsLambda"
      description = "Get all available wheels"
      handler     = "wheel.list_wheels"
    },
    {
      name        = "ResetWheelLambda"
      description = "Resets the weights of all participants of the wheel"
      handler     = "wheel.reset_wheel"
    },
    {
      name        = "RigParticipantLambda"
      description = "Rig the specified wheel for the specified participant.  Default behavior is comical rigging (hidden == False) but hidden can be specified to indicate deceptive rigging (hidden == True)"
      handler     = "wheel_participant.rig_participant"
    },
    {
      name        = "SelectParticipantLambda"
      description = "Indicates selection of a participant by the wheel.  This willc ause updates to the weights for all participants or removal of rigging if the wheel is rigged."
      handler     = "wheel_participant.select_participant"
    },
    {
      name        = "SuggestParticipantLambda"
      description = "Returns a suggested participant to be selected by the next wheel spin."
      handler     = "wheel_participant.suggest_participant"
    },
    {
      name        = "UnrigParticipantLambda"
      description = "Remove rigging for the specified wheel"
      handler     = "wheel.unrig_participant"
    },
    {
      name        = "UpdateParticipantLambda"
      description = "Update a participant's name and/or url"
      handler     = "wheel_participant.update_participant"
    },
    {
      name        = "UpdateWheelLambda"
      description = "Update the name of the wheel and/or refresh its participant count"
      handler     = "wheel.update_wheel"
    }
  ]
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  output_path = local.zip_filename
  source_dir  = "${path.root}/../lambda/python"
}

resource "aws_lambda_function" "lambda" {
  count = length(local.lambda_config)

  function_name = local.lambda_config[count.index].name
  description   = local.lambda_config[count.index].description
  handler       = local.lambda_config[count.index].handler

  role             = aws_iam_role.lambda_role.arn
  filename         = local.zip_filename
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  memory_size = local.memory_size
  runtime     = local.runtime
  timeout     = local.timeout

  vpc_config {
    subnet_ids = var.vpc_subnet_arn
    security_group_ids = var.allow_vpc_endpoints_security_group
  }

  environment {
    variables = local.env
  }
}