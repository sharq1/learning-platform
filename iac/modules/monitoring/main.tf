# Monitoring Module - Sets up Cloud Monitoring and Logging with alert policies

# Monitoring Metric for HTTP 5xx Error Rate for API service
resource "google_monitoring_alert_policy" "api_error_rate" {
  display_name = "API Service 5xx Error Rate Alert"
  combiner     = "OR"
  
  conditions {
    display_name = "Error rate exceeding threshold"
    
    condition_threshold {
      filter          = "resource.type = \"cloud_run_revision\" AND resource.labels.service_name = \"${var.service_name}\" AND metric.type = \"run.googleapis.com/request_count\" AND metric.labels.response_code_class = \"5xx\""
      duration        = "300s"  # 5 minutes
      comparison      = "COMPARISON_GT"
      threshold_value = var.error_rate_threshold
      
      aggregations {
        alignment_period     = "60s"
        per_series_aligner   = "ALIGN_RATE"
        cross_series_reducer = "REDUCE_SUM"
        group_by_fields      = ["resource.label.service_name"]
      }
      
      trigger {
        count = 1
      }
    }
  }
  
  notification_channels = var.notification_channels
  
  documentation {
    content   = "API service is experiencing a high rate of 5xx errors. Please investigate."
    mime_type = "text/markdown"
  }
  
  alert_strategy {
    auto_close = "1800s"  # 30 minutes
  }
}

# Latency monitoring for API service
resource "google_monitoring_alert_policy" "api_latency" {
  display_name = "API Service Latency Alert"
  combiner     = "OR"
  
  conditions {
    display_name = "Latency exceeding threshold"
    
    condition_threshold {
      filter          = "resource.type = \"cloud_run_revision\" AND resource.labels.service_name = \"${var.service_name}\" AND metric.type = \"run.googleapis.com/request_latencies\""
      duration        = "300s"  # 5 minutes
      comparison      = "COMPARISON_GT"
      threshold_value = 1000  # 1000ms = 1s
      
      aggregations {
        alignment_period     = "60s"
        per_series_aligner   = "ALIGN_PERCENTILE_99"
        cross_series_reducer = "REDUCE_MEAN"
        group_by_fields      = ["resource.label.service_name"]
      }
      
      trigger {
        count = 1
      }
    }
  }
  
  notification_channels = var.notification_channels
  
  documentation {
    content   = "API service is experiencing high latency. Please investigate."
    mime_type = "text/markdown"
  }
  
  alert_strategy {
    auto_close = "1800s"  # 30 minutes
  }
}

# CPU utilization monitoring for Cloud SQL
resource "google_monitoring_alert_policy" "cloudsql_cpu" {
  display_name = "Cloud SQL CPU Utilization Alert"
  combiner     = "OR"
  
  conditions {
    display_name = "CPU utilization exceeding threshold"
    
    condition_threshold {
      filter          = "resource.type = \"cloudsql_database\" AND metric.type = \"cloudsql.googleapis.com/database/cpu/utilization\""
      duration        = "300s"  # 5 minutes
      comparison      = "COMPARISON_GT"
      threshold_value = 0.8  # 80%
      
      aggregations {
        alignment_period     = "60s"
        per_series_aligner   = "ALIGN_MEAN"
      }
      
      trigger {
        count = 1
      }
    }
  }
  
  notification_channels = var.notification_channels
  
  documentation {
    content   = "Cloud SQL instance is experiencing high CPU utilization. Consider scaling up the instance."
    mime_type = "text/markdown"
  }
  
  alert_strategy {
    auto_close = "1800s"  # 30 minutes
  }
}

# Create a custom dashboard
resource "google_monitoring_dashboard" "learning_platform_dashboard" {
  dashboard_json = <<EOF
{
  "displayName": "Learning Platform Dashboard",
  "gridLayout": {
    "widgets": [
      {
        "title": "API Service Request Count",
        "xyChart": {
          "dataSets": [
            {
              "timeSeriesQuery": {
                "timeSeriesFilter": {
                  "filter": "resource.type = \"cloud_run_revision\" AND resource.labels.service_name = \"${var.service_name}\" AND metric.type = \"run.googleapis.com/request_count\"",
                  "aggregation": {
                    "alignmentPeriod": "60s",
                    "perSeriesAligner": "ALIGN_RATE",
                    "crossSeriesReducer": "REDUCE_SUM",
                    "groupByFields": [
                      "metric.labels.response_code_class"
                    ]
                  }
                }
              },
              "plotType": "LINE"
            }
          ]
        }
      },
      {
        "title": "API Service Latency",
        "xyChart": {
          "dataSets": [
            {
              "timeSeriesQuery": {
                "timeSeriesFilter": {
                  "filter": "resource.type = \"cloud_run_revision\" AND resource.labels.service_name = \"${var.service_name}\" AND metric.type = \"run.googleapis.com/request_latencies\"",
                  "aggregation": {
                    "alignmentPeriod": "60s",
                    "perSeriesAligner": "ALIGN_PERCENTILE_99"
                  }
                }
              },
              "plotType": "LINE"
            }
          ]
        }
      },
      {
        "title": "Cloud SQL CPU Utilization",
        "xyChart": {
          "dataSets": [
            {
              "timeSeriesQuery": {
                "timeSeriesFilter": {
                  "filter": "resource.type = \"cloudsql_database\" AND metric.type = \"cloudsql.googleapis.com/database/cpu/utilization\"",
                  "aggregation": {
                    "alignmentPeriod": "60s",
                    "perSeriesAligner": "ALIGN_MEAN"
                  }
                }
              },
              "plotType": "LINE"
            }
          ]
        }
      }
    ]
  }
}
EOF
}
