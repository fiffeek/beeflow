locals {
  schema_name = "public"
  table_mappings = {
    "rules" : [
      {
        "rule-type" : "selection",
        "rule-id" : "1",
        "rule-name" : "task_instance",
        "object-locator" : {
          "schema-name" : local.schema_name,
          "table-name" : "task_instance"
        },
        "rule-action" : "include"
      },
      {
        "rule-type" : "selection",
        "rule-id" : "2",
        "rule-name" : "dag_run",
        "object-locator" : {
          "schema-name" : local.schema_name,
          "table-name" : "dag_run"
        },
        "rule-action" : "include"
      },
      {
        "rule-type" : "selection",
        "rule-id" : "3",
        "rule-name" : "dag",
        "object-locator" : {
          "schema-name" : local.schema_name,
          "table-name" : "dag"
        },
        "rule-action" : "include"
      },
      {
        "rule-type" : "object-mapping",
        "rule-id" : "4",
        "rule-name" : "DefaultMapToKinesis-task_instance",
        "rule-action" : "map-record-to-record",
        "object-locator" : {
          "schema-name" : local.schema_name,
          "table-name" : "task_instance"
        }
      },
      {
        "rule-type" : "object-mapping",
        "rule-id" : "5",
        "rule-name" : "DefaultMapToKinesis-dag_run",
        "rule-action" : "map-record-to-record",
        "object-locator" : {
          "schema-name" : local.schema_name,
          "table-name" : "dag_run"
        }
      },
      {
        "rule-type" : "object-mapping",
        "rule-id" : "6",
        "rule-name" : "DefaultMapToKinesis-dag",
        "rule-action" : "map-record-to-record",
        "object-locator" : {
          "schema-name" : local.schema_name,
          "table-name" : "dag"
        }
      }
    ]
  }
}
