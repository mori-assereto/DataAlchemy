

{% set dimensions = [ 'country',
                      'partner',
                      'product',
                      'origin',
                      'enterprise' ] %}

with arps as (

  select
    *
  from
    {{ ref('metrics_arps') }}

), churn as (

  select
    month
    {% for dimension in dimensions -%}
    , {{ dimension }}
    {% endfor -%}
    , sum(subscriptions_lost)
          as subscriptions_lost
    , sum(paying_subscriptions_on_previous_month)
           as paying_subscriptions_on_previous_month
  from
    {{ ref('metrics_churn') }}
  {{ dbt_utils.group_by(n=(1 + (dimensions | length))) }}

)

select
  coalesce(churn.month, arps.month) as month
  {% for dimension in dimensions -%}
    , coalesce(churn.{{ dimension }}, arps.{{ dimension }})
            as {{ dimension }}
  {% endfor -%}
  , arps.revenue_usd
  , arps.subscriptions
            as paying_subscriptions_on_current_month
  , churn.subscriptions_lost
  , churn.paying_subscriptions_on_previous_month
from churn
full outer join arps
  on churn.month = arps.month
  and
  {% for dimension in dimensions -%}
    (( churn.{{ dimension }} = arps.{{ dimension }} )
    or(churn.{{ dimension }} is null and arps.{{ dimension }} is null))
    {{ 'and' if not loop.last }}
  {% endfor %}
