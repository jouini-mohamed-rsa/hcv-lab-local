locals {

  helm_chart_name = (
    var.helm_repository != null
    ? var.helm_chart
    : var.helm_chart_name != null
      ? var.helm_chart_name
      : regex("([^/]+)$", var.helm_chart)[0]  # extract last segment
  )

  helm_metadata = merge(
    {
      for ann_name, ann_value in var.helm_metadata : "globalAnnotations.${ann_name}" => ann_value
    },
    {
      "globalAnnotations.team_region"    = var.team_region
      "globalAnnotations.team_name"      = var.team_name
    }
  )

}
