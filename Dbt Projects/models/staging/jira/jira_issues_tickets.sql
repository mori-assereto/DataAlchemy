{{ config(materialized='table') }}

{{ dbt_utils.union_relations(
    relations=[
      ref('jira_issues_old_tickets'),
      ref('jira_issues_new_tickets'),
    ]
)}}
