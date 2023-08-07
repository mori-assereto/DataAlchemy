{% set typification_ids = [ '1260809373350'] %}


with

 "tickets_custom_fields" as (

  select
      "tickets_custom_fields"."ticket_id"
    , "tickets_custom_fields"."id" as "ticket_field_id"
    , "tickets_custom_fields"."value__string"
  from
    {{ ref('zk_tickets_custom_fields') }} "tickets_custom_fields"
  where
    "tickets_custom_fields"."value__string" <> ''

)

, "tickets_fields" as (

  select
      "tickets_fields"."id"
    , "tickets_fields"."title"
  from
    {{ source('zendesk', 'ticket_fields') }} "tickets_fields"
  where
  (
    {% for typification_id in typification_ids %}
        ("tickets_fields"."id" = '{{ typification_id }}') {{ 'or' if not loop.last }}
    {% endfor %}
  )

)

, "results" as (

  select distinct
      "tickets_custom_fields"."ticket_id"
    , "tickets_custom_fields"."value__string" as "scaling"

  from "tickets_custom_fields"
  inner join "tickets_fields"
    on "tickets_fields"."id" = "tickets_custom_fields"."ticket_field_id"


)

select * from "results"
