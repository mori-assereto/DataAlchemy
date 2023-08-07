with "tickets_tags" as (

  select
      "tickets_tags"."_sdc_source_key_id" as "ticket_id"
    , "tickets_tags"."value"
  from {{ source('zendesk', 'tickets__tags') }} "tickets_tags"
  where
    "tickets_tags"."value" = 'closed_by_merge'

)

select * from "tickets_tags"
