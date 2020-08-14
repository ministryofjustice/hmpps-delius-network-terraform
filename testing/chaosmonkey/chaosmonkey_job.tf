# Create Chaosmonkey specific AWS Batch Job Definition
data "template_file" "chaosmonkey_job_template" {
  template = file("./templates/batch_jobs/chaosmonkey.tpl")

  vars = {
    job_image  = var.chaosmonkey_job_image
    job_role   = aws_iam_role.job_role.arn
    job_memory = var.chaosmonkey_job_memory
    job_vcpus  = var.chaosmonkey_job_vcpus
    # Map of environment vars - These can be appended to at run time
    job_envvars = jsonencode(var.chaosmonkey_job_envvars)
    # Job specific ulimits - with horrible TF workaround for keeping integers post marshalling - fixed in TF 0.12
    # see https://github.com/hashicorp/terraform/issues/17033
    job_ulimits = replace(
      replace(
        jsonencode(var.chaosmonkey_job_ulimits),
        "/\"([[:digit:]]+)\"/",
        "$1",
      ),
      "string:",
      "",
    )
  }
}

resource "aws_batch_job_definition" "chaosmonkey_job_def" {
  name = "${local.name_prefix}-testing-job"
  type = "container"

  retry_strategy {
    attempts = var.chaosmonkey_job_retries
  }

  # Rendered Job Definition from template
  container_properties = data.template_file.chaosmonkey_job_template.rendered
}

