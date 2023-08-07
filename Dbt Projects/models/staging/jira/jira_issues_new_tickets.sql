with

"jira_issues" as (

  select
      "issues"."key"                      as "jira_card_number"
    , "issues"."fields__status__name"     as "jira_status"
    , "issues"."fields__issuetype__name"  as "jira_issue_type"
    , "issues"."fields__summary"          as "jira_card_name"
    , "issues"."fields__created"          as "jira_card_created_at"
  from
    {{ source('jira', 'issues') }} "issues"

)

select * from "jira_issues"
