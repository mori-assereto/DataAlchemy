{% set pay = var('products')['pay'] %}

with subscriptions as (

  select
    "subscriptions"."id"
  from
    {{ ref('platform_subscriptions') }} "subscriptions"
  left join {{ ref('platform_accounts') }} "accounts"
    on "accounts"."id" = "subscriptions"."account_id"
  where
    "subscriptions"."state" = 'usable'
    and "subscriptions"."initial_billing" < current_timestamp - interval '24 hours'
    and not "accounts"."is_test"
    and not "accounts"."is_demo"
    and "subscriptions"."product" <> '{{ pay["name"] }}'

), consumptions as (

  select id, subscription_id from {{ ref('platform_consumptions') }}

)

select
  subscriptions.id
from
  subscriptions
left join consumptions
  on subscriptions.id = consumptions.subscription_id
group by
  1
having
  count(consumptions.id) = 0
