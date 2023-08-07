with

 "tickets_custom_fields" as (

  select
      "tickets_custom_fields"."ticket_id"
    , "tickets_custom_fields"."id" as "ticket_field_id"
    , "tickets_custom_fields"."value__string"
  from
    {{ ref('zk_tickets_custom_fields') }} "tickets_custom_fields"

)

, "tickets_fields" as (

  select
      "tickets_fields"."id"
    , "tickets_fields"."title"
  from
    {{ source('zendesk', 'ticket_fields') }} "tickets_fields"
  where
    -- Post migration of Zendesk the ticket filed column with title
    -- "Tipificación Baja" has id 360038788113
    "tickets_fields"."id" = '26385128'

)

, "results" as (

  select
      "tickets_custom_fields"."ticket_id" as "ticket_id"
    , "tickets_custom_fields"."value__string"
                     as "type_of_consulting"
  from "tickets_custom_fields"
  inner join "tickets_fields"
    on "tickets_fields"."id" = "tickets_custom_fields"."ticket_field_id"
  where
    "tickets_custom_fields"."value__string" is not null
      and "tickets_custom_fields"."value__string" <> ''


)

select * from "results"
