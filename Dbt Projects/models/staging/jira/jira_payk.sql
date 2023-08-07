with

"results" as (

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
    , "issues"."fields__customfield_10147__value"
                                          as "reporter_circle"
    , "issues"."fields__customfield_10148"
                                          as "reported_at"
    , "issues"."fields__customfield_10150__value"
                                          as "l1_typification"
    , "issues"."fields__customfield_10151__value"
                                          as "l2_typification"
    , "issues"."fields__customfield_10152__value"
                                          as "payment_method"
  from
    {{ source('jira', 'issues') }} "issues"
  where
    "issues"."fields__project__id" = '10088'
    and
    -- Filter de ID's that where deleted from PAYK
      "issues"."id" not in ('19778',
                            '21298',
                            '19851',
                            '19869',
                            '20349',
                            '19806',
                            '20392',
                            '19749',
                            '20121',
                            '19763',
                            '19813',
                            '19829',
                            '20213',
                            '20272',
                            '19852',
                            '21172',
                            '20070',
                            '20096',
                            '21300',
                            '21222',
                            '21111',
                            '21270',
                            '19772',
                            '20117',
                            '19771',
                            '21112',
                            '20875',
                            '21299',
                            '20092',
                            '20093',
                            '20094',
                            '20091',
                            '19804',
                            '21608')
)

select * from "results"
