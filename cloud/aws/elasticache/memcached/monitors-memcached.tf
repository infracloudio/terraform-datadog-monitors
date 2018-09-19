module "datadog-monitors-aws-elasticache-common" {
  source = "../common"

  message     = "${var.message}"
  environment = "${var.environment}"
  filter_tags = "${data.template_file.filter.rendered}"
  resource    = "memcached"

  delay = "${var.evaluation_delay}"

  eviction_message         = "${var.eviction_message}"
  eviction_silenced        = "${var.eviction_silenced}"
  eviction_time_aggregator = "${var.eviction_time_aggregator}"
  eviction_timeframe       = "${var.eviction_timeframe}"

  eviction_growing_condition_timeframe = "${var.eviction_growing_condition_timeframe}"
  eviction_growing_timeframe           = "${var.eviction_growing_timeframe}"
  eviction_growing_message             = "${var.eviction_growing_message}"
  eviction_growing_silenced            = "${var.eviction_growing_silenced}"
  eviction_growing_threshold_warning   = "${var.eviction_growing_threshold_warning}"
  eviction_growing_threshold_critical  = "${var.eviction_growing_threshold_critical}"

  free_memory_condition_timeframe = "${var.free_memory_condition_timeframe}"
  free_memory_timeframe           = "${var.free_memory_timeframe}"
  free_memory_message             = "${var.free_memory_message}"
  free_memory_silenced            = "${var.free_memory_silenced}"
  free_memory_threshold_critical  = "${var.free_memory_threshold_critical}"
  free_memory_threshold_warning   = "${var.free_memory_threshold_warning}"

  max_connection_message         = "${var.max_connection_message}"
  max_connection_silenced        = "${var.max_connection_silenced}"
  max_connection_time_aggregator = "${var.max_connection_time_aggregator}"
  max_connection_timeframe       = "${var.max_connection_timeframe}"

  no_connection_message         = "${var.no_connection_message}"
  no_connection_silenced        = "${var.no_connection_silenced}"
  no_connection_time_aggregator = "${var.no_connection_time_aggregator}"
  no_connection_timeframe       = "${var.no_connection_timeframe}"

  swap_message            = "${var.swap_message}"
  swap_silenced           = "${var.swap_silenced}"
  swap_threshold_critical = "${var.swap_threshold_critical}"
  swap_threshold_warning  = "${var.swap_threshold_warning}"
  swap_time_aggregator    = "${var.swap_time_aggregator}"
  swap_timeframe          = "${var.swap_timeframe}"
}

resource "datadog_monitor" "memcached_get_hits" {
count = "${var.get_hits_enabled ? 1 : 0}"
  name    = "[${var.environment}] Elasticache memcached get hits {{#is_alert}}{{{comparator}}} {{threshold}}% ({{value}}%){{/is_alert}}{{#is_warning}}{{{comparator}}} {{warn_threshold}}% ({{value}}%){{/is_warning}}"
  message = "${coalesce(var.get_hits_message, var.message)}"

  type = "metric alert"

  query = <<EOF
    sum(${var.get_hits_timeframe}): (
      avg:aws.elasticache.get_hits${module.filter-tags.query_alert} by {region,cacheclusterid}.as_count() /
      (avg:aws.elasticache.get_hits${module.filter-tags.query_alert} by {region,cacheclusterid}.as_count() +
        avg:aws.elasticache.get_misses${module.filter-tags.query_alert} by {region,cacheclusterid}.as_count())
    ) < ${var.get_hits_threshold_critical}
  EOF

  thresholds {
    warning  = "${var.get_hits_threshold_warning}"
    critical = "${var.get_hits_threshold_critical}"
  }

  notify_no_data      = true
  evaluation_delay    = "${var.evaluation_delay}"
  renotify_interval   = 0
  notify_audit        = false
  timeout_h           = 0
  include_tags        = true
  locked              = false
  require_full_window = false
  new_host_delay      = "${var.new_host_delay}"

  silenced = "${var.get_hits_silenced}"

  tags = ["env:${var.environment}", "type:cloud", "provider:aws", "resource:elasticache-memcached", "team:claranet", "created-by:terraform", "${var.get_hits_extra_tags}"]
}

resource "datadog_monitor" "memcached_cpu_high" {
count = "${var.cpu_high_enabled ? 1 : 0}"
  name    = "[${var.environment}] Elasticache memcached CPU {{#is_alert}}{{{comparator}}} {{threshold}}% ({{value}}%){{/is_alert}}{{#is_warning}}{{{comparator}}} {{warn_threshold}}% ({{value}}%){{/is_warning}}"
  message = "${coalesce(var.cpu_high_message, var.message)}"

  type = "metric alert"

  query = <<EOF
    ${var.cpu_high_time_aggregator}(${var.cpu_high_timeframe}): (
      avg:aws.elasticache.cpuutilization${module.filter-tags.query_alert} by {region,cacheclusterid,cachenodeid}
    ) > ${var.cpu_high_threshold_critical}
  EOF

  thresholds {
    warning  = "${var.cpu_high_threshold_warning}"
    critical = "${var.cpu_high_threshold_critical}"
  }

  notify_no_data      = true
  evaluation_delay    = "${var.evaluation_delay}"
  renotify_interval   = 0
  notify_audit        = false
  timeout_h           = 0
  include_tags        = true
  locked              = false
  require_full_window = false
  new_host_delay      = "${var.new_host_delay}"

  silenced = "${var.cpu_high_silenced}"

  tags = ["env:${var.environment}", "type:cloud", "provider:aws", "resource:elasticache-memcached", "team:claranet", "created-by:terraform", "${var.cpu_high_extra_tags}"]
}
