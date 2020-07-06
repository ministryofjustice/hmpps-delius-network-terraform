
output "strategic_public_zone_id" {
  # Currently we do not create the strategic_zone in Production, as it is still managed by Ansible unlike the other
  # environments. We conditionally create this by using a tertiary statement in the `count` field on the relevant
  # resources (see zones.tf). Due to using `count`, we need to output this value using a splat statement which returns
  # a list of IDs that is either empty in Production or contains a single string in other environments. However in
  # Production the output is stored in terraform state as a string, making it incosistent with the other environments.
  # Because of this, we use join() to convert both case sto a string, to match our other zone outputs and to ensure we
  # use the same type for all environments.
  # Note this solution only makes sense when we have a count of 1 or 0.
  # See https://www.terraform.io/docs/configuration/functions/join.html
  value = "${join("", aws_route53_zone.strategic_zone.*.id)}"
}

output "strategic_public_zone_name" {
  value =  "${local.strategic_public_domain}"
}

