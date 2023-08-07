with metrics_mrr as (

  select
    month
    , sum(mrr) as metrics_mrr
  from
    {{ ref('metrics_mrr') }}
  group by
    1

), churn_mrr as (

  select
    add_months(month, -1) as month
    , sum(mrr_previous_month)
               as churn_mrr
  from
    {{ref('metrics_mrr_churn') }}
  group by
    1

)

select
  m.month
  , m.metrics_mrr
  , c.churn_mrr
from metrics_mrr m
left join churn_mrr c
  on m.month = c.month
where
  round(m.metrics_mrr, 2) <> round(c.churn_mrr, 2)
