{% set acquisition_pipeline_id = 'default' %}

with

"deals_cycle" as (

  select
      "deals"."dealid"  as "deal_id"
    , "deals"."properties__dealname__value"
                        as "name"
    , {{ hubspot_stage_name('"deals"."properties__dealstage__value"') }}
                        as "stage"
    , "deals"."properties__plan__value"
                        as "plan"
    , "deals"."properties__country__value"
                        as "country"
    , "deals"."properties__partner__value"
                        as "partner"
    , "deals"."properties__subscription_id__value"
                        as "subscription_id"
    , "deals"."properties__increaser_onb__value"
                        as "increaser_onb"
    , "deals"."properties__collect_method__value"
                        as "collect_method"
    , "deals"."properties__datos_de_facturacion_validados__value"
                        as "has_billing_info"
    , {{ unix_timestamp_convert('"deals"."properties__fecha_reunion_onboarding__value"') }}
                        as "onboarding_meeting"
    , "deals"."properties__paso_a_usable__value"
                        as "is_usable"
    , "deals"."properties__cargo_collect_method__value"
                        as "has_collect_method"
    , "deals"."properties__tiene_core_action__value"
                        as "has_core_action"
    , {{ unix_timestamp_convert('"deals"."properties__fecha_capacitacion__value"') }}
                        as "training_meeting"
    , "deals"."properties__hs_date_entered_11743216__value"
                        as "created_lead_entered_date"
    , "deals"."properties__hs_date_entered_29057618__value"
                        as "introduction_entered_date"
    , "deals"."properties__hs_date_exited_29057618__value"
                        as "introduction_exited_date"
    , datediff (day,"introduction_entered_date", "introduction_exited_date")
                        as "introduction_duration"
    , "deals"."properties__hs_date_entered_29057619__value"
                        as "training_entered_date"
    , "deals"."properties__hs_date_exited_29057619__value"
                        as "training_exited_date"
    , datediff (day,"training_entered_date", "training_exited_date")
                        as "training_duration"
    , "deals"."properties__hs_date_entered_29057620__value"
                        as "boost_entered_date"
    , "deals"."properties__hs_date_exited_29057620__value"
                        as "boost_exited_date"
    , datediff (day,"boost_entered_date", "boost_exited_date")
                        as "boost_duration"
    , "deals"."properties__hs_date_entered_29057621__value"
                        as "aha_moment_date"
    , datediff (day,"created_lead_entered_date", "aha_moment_date")
                        as "total_days_to_aha_moment"
    , date_trunc('month', "created_lead_entered_date")
                        as "date_month"
    , "deals"."properties__hs_date_entered_closedlost__value"
                        as "closed_lost_date"
    , "deals"."property_closed_lost_reason__v2___value"
                        as "pay_closed_lost_reason"
    , datediff (day,"introduction_entered_date", coalesce("aha_moment_date", current_date))
                        as "acquisition_lifetime"
    , "introduction_entered_date" is not null
                        as "has_introduction_stage"
    , "training_entered_date" is not null
                        as "has_training_stage"
    , "boost_entered_date" is not null
                        as "has_boost_stage"
    , "aha_moment_date" is not null
                        as "has_aha_moment_stage"
    , "closed_lost_date" is not null
                        as "has_closed_lost_stage"
  from
    {{ source('hubspot', 'deals') }} "deals"
  where
    "deals"."properties__pipeline__value" = '{{ acquisition_pipeline_id }}'
    and
      "deals"."properties__dealstage__value" in ( '29057618','29057619',
                                                  '29057620','29057621')

)

, "owners" as (

  select
      "owners"."ownerid" as "owner_id"
    , "owners"."email"
  from
    {{ source('hubspot', 'owners') }} "owners"

)

, "results" as (

  select
    "deals_cycle".*
    , "owners"."email"
  from "deals_cycle"
  left join "owners"
    on "deals_cycle"."increaser_onb" = "owners"."owner_id"

)

select * from "results"
