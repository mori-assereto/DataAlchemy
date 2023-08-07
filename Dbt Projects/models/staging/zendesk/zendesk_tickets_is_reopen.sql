with "tickets_reopen" as (

  select
      "ticket_metrics"."ticket_id"
    , "ticket_metrics"."reopens" > 0 as "is_reopen"
  from
    {{ source('zendesk', 'ticket_metrics') }} "ticket_metrics"

)

select * from "tickets_reopen"
