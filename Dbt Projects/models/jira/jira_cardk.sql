with

"jira_issues" as (

  select
      "issues"."id"
    , "issues"."key"                      as "jira_card_number"
    , "issues"."fields__project__key"     as "jira_project"
    , "issues"."fields__status__name"     as "jira_card_status"
    , "issues"."fields__issuetype__name"  as "jira_issue_type"
    , "issues"."fields__priority__name"   as "jira_priority"
    , "issues"."fields__assignee__displayname"
                                          as "assignee_name"
    , "issues"."fields__creator__displayname"
                                          as "creator_name"
    , "issues"."fields__reporter__displayname"
                                          as "reporter_name"
    , "issues"."fields__summary"          as "jira_card_name"
    , "issues"."fields__created"          as "created_at"
    , "issues"."fields__updated"          as "updated"
    , "issues"."fields__customfield_10084__value"
                                          as "info_provider"
    , "issues"."fields__customfield_10165__value"
                                          as "credential_type"
    , "issues"."fields__customfield_10086__value"
                                          as "document_type"


  from
    {{ source('jira', 'issues') }} "issues"
  where
  -- It's CARDK project id
    "issues"."fields__project__id" = '10051'

)
, "changelogs" as (

  select
      "changelogs"."id"
    , "changelogs"."issueid"       as "issue_id"
    , "changelogs"."created"::date as "created_at"
  from
    {{ source('jira', 'changelogs') }} "changelogs"

)

, "resolution_changelog" as (

  select
    "items"."_sdc_source_key_id" as "changelog_id"
  from
    {{ source('jira', 'changelogs__items') }} "items"
  where
    "items"."fieldid" = 'resolution'
    and "items"."tostring" = 'Done'

)

, "issues_solved_at" as (

  select
      "changelogs"."issue_id"
    , max("changelogs"."created_at") as "solved_at"
  from
    "resolution_changelog"
  inner join "changelogs"
    on "resolution_changelog"."changelog_id" = "changelogs"."id"
  inner join "jira_issues"
    on "changelogs"."issue_id" = "jira_issues"."id"
  where
    -- Consider only solved issues, to avoid a reverted transition to Done
    "jira_issues"."jira_card_status" = 'DONE'
    or "jira_issues"."jira_card_status" = 'FINALIZADAS'
  group by
    1

)
, "results" as (

  select
      "jira_issues".*
    , "issues_solved_at"."solved_at"
    , datediff('days',
               "jira_issues"."created_at"::date,
               coalesce("issues_solved_at"."solved_at"::date, current_date))
                                                        as "days_to_repair"
  from
    "jira_issues"
  left join "issues_solved_at"
    on "jira_issues"."id" = "issues_solved_at"."issue_id"

)

select * from "results"
