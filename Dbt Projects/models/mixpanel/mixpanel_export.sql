with "export" as (

  select
      {{ dbt_utils.star(from=source('mixpanel', 'mixpanel_export') , except=['impersonator email']) }}
    , "mixpanel_export"."impersonator email" as "impersonator_email"
  from
    {{ source('mixpanel', 'mixpanel_export') }} "mixpanel_export"
)
select
  *
from
  "export"
