with

"jira_issues" as (

  select
      "payk".*
  from
    {{ ref('jira_payk') }} "payk"

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
    "jira_issues"."jira_card_status" = 'Done'
  group by
    1

)
, "results" as (

  select
      "jira_issues".*
    , "issues_solved_at"."solved_at"
    , datediff('days',
               "jira_issues"."reported_at"::date,
               "jira_issues"."created_at"::date)       as "days_to_report"
    , datediff('days',
               "jira_issues"."created_at"::date,
               coalesce("issues_solved_at"."solved_at"::date, current_date))
                                                        as "days_to_repair"
    , datediff('days',
               "jira_issues"."reported_at"::date,
               coalesce("issues_solved_at"."solved_at"::date, current_date))
                                                        as "days_to_unsolved"
  from
    "jira_issues"
  left join "issues_solved_at"
    on "jira_issues"."id" = "issues_solved_at"."issue_id"

)

select * from "results"
