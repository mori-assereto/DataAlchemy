

{% set dims = [ 'product', 'country',
                'partner', 'partners_type', 'contact_center',
                'contact_center_type', 'payment_method',
                'origin', 'enterprise', 'pay_plan'] %}

with

"individual_quantity_won" as (

  select
      "subscriptions_won"."initial_month" as "month"
    {% for dimension in dims %}
    , "subscriptions_won"."{{ dimension }}"
    {% endfor %}
    , count(*) as "subscriptions_won"
  from {{ ref('metrics_churn_subscription_won') }} "subscriptions_won"
  {{ dbt_utils.group_by(n=(1 + (dims | length))) }}
  order by 1

)

, "individual_quantity_lost" as (

  select
      "subscriptions_lost"."canceled_month" as "month"
    {% for dimension in dims %}
    , "subscriptions_lost"."{{ dimension }}"
    {% endfor %}
    , count(*) as "subscriptions_lost"
  from {{ ref('metrics_churn_subscription_lost') }} "subscriptions_lost"
  {{ dbt_utils.group_by(n=(1 + (dims | length))) }}
  order by 1

)

, "calendar" as (

  select
    "calendar".*
  from
    {{ ref('metrics_churn_calendar') }} "calendar"

)

, "results" as (

  select
      "calendar"."month"
    {% for dimension in dims %}
    , "calendar"."{{ dimension }}"
    {% endfor %}
    , coalesce("individual_quantity_won"."subscriptions_won", 0)::float
            as "subscriptions_won"
    , coalesce("individual_quantity_lost"."subscriptions_lost", 0)::float
            as "subscriptions_lost"
    , (sum(coalesce("individual_quantity_won"."subscriptions_won", 0))
          over (partition by
                      {% for dimension in dims -%}
                      "calendar"."{{ dimension }}" {{ ',' if not loop.last }}
                      {%- endfor %}
                order by "calendar"."month"
                rows unbounded preceding)
      )::float as "cumulative_subscriptions_won"
    , (sum(coalesce("individual_quantity_lost"."subscriptions_lost", 0))
        over (partition by
                    {% for dimension in dims %}
                    "calendar"."{{ dimension }}" {{ ',' if not loop.last }}
                    {% endfor %}
              order by "calendar"."month"
              rows unbounded preceding)
      )::float as "cumulative_subscriptions_lost"
    , ((coalesce("cumulative_subscriptions_won", 0) - coalesce("subscriptions_won", 0)) -
       (coalesce("cumulative_subscriptions_lost", 0) - coalesce("subscriptions_lost", 0)))::float
                                              as "paying_subscriptions_on_previous_month"
    , coalesce("paying_subscriptions_on_previous_month", 0 ) - coalesce("subscriptions_lost", 0)
      + coalesce("subscriptions_won", 0)      as "paying_subscriptions_on_current_month"
  from
    "calendar"
  left join "individual_quantity_won"
    on "individual_quantity_won"."month" = "calendar"."month" and
    {% for dimension in dims -%}
    (("individual_quantity_won"."{{ dimension }}" = "calendar"."{{ dimension }}")
      or ("individual_quantity_won"."{{ dimension }}" is null
          and "calendar"."{{ dimension }}" is null))
    {{ 'and' if not loop.last }}
    {%- endfor %}
  left join "individual_quantity_lost"
    on "calendar"."month" = "individual_quantity_lost"."month" and
    {% for dimension in dims -%}
    (("calendar"."{{ dimension }}" = "individual_quantity_lost"."{{ dimension }}")
      or ("individual_quantity_lost"."{{ dimension }}" is null
          and "calendar"."{{ dimension }}" is null))
    {{ 'and' if not loop.last }}
    {%- endfor %}

)

select * from "results"
