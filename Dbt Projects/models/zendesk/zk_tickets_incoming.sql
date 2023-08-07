with

"ticket_audits_events" as (

  select
      "ticket_audits_events"."_sdc_source_key_id" as "audit_id"
    , "ticket_audits_events"."_sdc_received_at" as "date_day"
  from
    {{ source('zendesk', 'ticket_audits__events') }} "ticket_audits_events"
  where
    "ticket_audits_events"."field_name" = 'status'
    and
    (
      ("ticket_audits_events"."type" = 'Create')
      or
      ("ticket_audits_events"."type" = 'Change'
        and "ticket_audits_events"."previous_value" = 'solved'
        and ("ticket_audits_events"."value" <> 'closed'
          or "ticket_audits_events"."value" is null))
    )

)

, "ticket_audits" as (

  select
      "ticket_audits"."id"
    , "ticket_audits"."ticket_id"
  from
    {{ source('zendesk', 'ticket_audits') }} "ticket_audits"

)

, "results" as (

  select
      "ticket_audits_events"."audit_id"
    , "ticket_audits_events"."date_day"
    , "ticket_audits"."ticket_id"
  from "ticket_audits_events"
  inner join "ticket_audits"
    on "ticket_audits_events"."audit_id" = "ticket_audits"."id"

)

select * from "results"
