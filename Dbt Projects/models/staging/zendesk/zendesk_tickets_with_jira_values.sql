with

"tickets_with_jira_card_number" as (

  select
      "tickets_custom_fields"."ticket_id"
    , "tickets_custom_fields"."value__string"      as "jira_card_number"
  from
    {{ ref('zk_tickets_custom_fields') }} "tickets_custom_fields"
  where
    -- Card Number JIRA id's
    "tickets_custom_fields"."id" = '360025706034'
    and ("tickets_custom_fields"."value__string" is not null
      or "tickets_custom_fields"."value__string" <> ' ')

)

, "jira_issues" as (

  select
      "issues"."jira_card_number"
    , "issues"."jira_status"
    , "issues"."jira_issue_type"
    , "issues"."jira_card_name"
    , "issues"."jira_card_created_at"
  from
    {{ ref('jira_issues_tickets') }} "issues"

)


, "results" as (

  select 
      "jira_issues".*
    , "tickets_with_jira_card_number"."ticket_id"
  from "tickets_with_jira_card_number"
  inner join "jira_issues"
    on "tickets_with_jira_card_number"."jira_card_number" = "jira_issues"."jira_card_number"

)

select * from "results"
