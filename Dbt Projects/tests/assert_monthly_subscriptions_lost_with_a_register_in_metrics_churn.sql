{{ config(severity='warn') }}

with subscription as (

select distinct
  date_trunc('month', canceled_at) as canceled_month
from
  {{ ref('platform_subscriptions') }}
where
  subscription_lost = 1

), churn as (

select
  month
from
  {{ ref('metrics_churn') }}
group by
  1
having
  sum(subscriptions_lost) > 0

)

select
  canceled_month
from
  subscription
left join churn
  on churn.month = subscription.canceled_month
where churn.month is null
