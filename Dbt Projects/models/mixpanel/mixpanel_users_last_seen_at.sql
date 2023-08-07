{{ config(materialized='ephemeral') }}

select
  distinct_id   as email
  , max("time") as last_seen_at
from
  {{ source('mixpanel', 'mixpanel_export') }}
group by
  1
