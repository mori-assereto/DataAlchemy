{% set group_ids = ['360011029354',
                    '360009760593',
                    '360009760473',
                    '360009757234',
                    '25197867',
                    '360009757254'] %}

with

"ticket_comments" as (

  select
      "ticket_comments"."ticket_id"
    , "ticket_comments"."created_at" as "date_day"
    , "ticket_comments"."author_id"
  from
    {{ source('zendesk', 'ticket_comments') }} "ticket_comments"
  where
    "ticket_comments"."public" = true

)

, "ticket_users" as (

  select
    "ticket_users"."id"
  from
    {{ source('zendesk', 'users') }} "ticket_users"
  where
  (
    {% for group_id in group_ids %}
        ("ticket_users"."default_group_id" = '{{ group_id }}') {{ 'or' if not loop.last }}
    {% endfor %}
  )

)

, "results" as (

  select
      "ticket_comments"."ticket_id"
    , "ticket_comments"."date_day"
  from "ticket_comments"
  inner join "ticket_users"
    on "ticket_comments"."author_id" = "ticket_users"."id"

)

select * from "results"
