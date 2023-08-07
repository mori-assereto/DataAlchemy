{% set typification_ids = [ '360038788113',
                            '360038788533',
                            '360038788573',
                            '360038789773',
                            '360043546474',
                            '360045946734',
                            '1260805692010'] %}

with

 "tickets_custom_fields" as (

  select
      "tickets_custom_fields"."ticket_id"
    , "tickets_custom_fields"."id" as "ticket_field_id"
    , "tickets_custom_fields"."value__string"
    , "tickets_custom_fields"."_sdc_batched_at" as "date_day"
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
    , last_value("tickets_fields"."title")
                          over (partition by "tickets_custom_fields"."ticket_id"
                                order by "tickets_custom_fields"."date_day"
                                  rows between unbounded preceding
                                  and unbounded following)
                                as "typification_l1"
    , last_value("tickets_custom_fields"."value__string")
                          over (partition by "tickets_custom_fields"."ticket_id"
                                order by "tickets_custom_fields"."date_day"
                                  rows between unbounded preceding
                                  and unbounded following)
                                as "value_typification_l1"

  from "tickets_custom_fields"
  inner join "tickets_fields"
    on "tickets_fields"."id" = "tickets_custom_fields"."ticket_field_id"


)

select * from "results"
