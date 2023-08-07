{% set session_minutes = var('mixpanel_session_duration') %}

with export as (
  select
    "distinct_id"
    , "product"
    , "time"
  from
    {{ source('mixpanel', 'mixpanel_export') }}
), events_with_time_difference as (
  select
    "distinct_id"
    , "product"
    , "time"
    , lag("time") over ( partition by "distinct_id"
                         order by "time" asc
                       )       as "previous_time"
    , "time" - "previous_time" as "time_difference"
  from
    export
), start_of_sessions as (
  select
    *
    , case
        when "time_difference" >= interval '{{ session_minutes }}'
            or "previous_time" is null
          then 1
        else 0
      end as "is_new_session"
  from
    events_with_time_difference
)
select
  *
  , sum("is_new_session") over ( partition by "distinct_id"
                                 order by "time" asc
                                 rows between unbounded preceding and current row
                               ) as "user_session_id"
from
  start_of_sessions
