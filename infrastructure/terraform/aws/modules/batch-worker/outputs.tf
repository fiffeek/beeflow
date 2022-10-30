output "job_definition_name" {
  value = module.worker.job_definitions["airflow_task"].name
  description = "The job definition name"
}

output "job_queue_name" {
  value = module.worker.job_queues["queue"].name
  description = "The job queue name"
}
