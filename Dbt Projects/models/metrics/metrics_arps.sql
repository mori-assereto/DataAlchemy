{% set dimensions = [ 'country',
                      'partner',
                      'product',
                      'origin',
                      'enterprise' ] %}

with revenue as (

    select
      month
      {% for dimension in dimensions -%}
      , {{ dimension }}
      {% endfor -%}
      , sum(revenue_usd) as revenue_usd
    from
      {{ ref('metrics_revenue') }}
    {{ dbt_utils.group_by(n=(1 + (dimensions | length))) }}

), paying_subscriptions as (

    select
      month
      {% for dimension in dimensions -%}
      , {{ dimension }}
      {% endfor -%}
      , sum(paying_subscriptions_on_current_month) as subscriptions
    from
      {{ ref('metrics_churn') }}
    {{ dbt_utils.group_by(n=(1 + (dimensions | length))) }}

)
select
  coalesce(r.month, s.month) as month
  {% for dimension in dimensions -%}
    , coalesce(r.{{ dimension }}, s.{{ dimension }}) as {{ dimension }}
  {% endfor -%}
  , revenue_usd
  , subscriptions
from
    revenue r
full outer join paying_subscriptions s
    on r.month = s.month and
    {% for dimension in dimensions -%}
      (( r.{{ dimension }} = s.{{ dimension }} )
      or(r.{{ dimension }} is null and s.{{ dimension }} is null))
      {{ 'and' if not loop.last }}
    {% endfor %}
