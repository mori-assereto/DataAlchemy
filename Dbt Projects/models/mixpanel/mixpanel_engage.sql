with "engage" as (

  select * from {{ source('mixpanel', 'mixpanel_engage') }} "mixpanel_engage"

)

select
  *
from
  "engage"
