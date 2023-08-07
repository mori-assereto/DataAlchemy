with platform_subscriptions as (

  select
    id
  from
    {{ ref('platform_subscriptions') }}
  where
    created_at < current_date - 1

), source_subscriptions as (

  select
    id
  from
    {{ source('platform', 'subscriptions') }}
  where
    created_at < current_date - 1

)
select
  p.id
  , s.id
from
  platform_subscriptions p
full outer join source_subscriptions s
  on p.id = s.id
where
  p.id is null or s.id is null
