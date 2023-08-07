{{ config(
    materialized='table',
    sort=['date_day'],
    sort_type='compound',
    dist='all'
  )
}}


with calendar as (

    {{ dbt_utils.date_spine(
        datepart="day",
        start_date="to_date('01/01/2015', 'dd/mm/yyyy')",
        end_date="dateadd(week, 1, current_date)"
      )
    }}

)

select
  date_trunc('year', c.date_day)    as date_year
  , date_trunc('quarter', c.date_day)
                                    as date_quarter
  , date_trunc('month', c.date_day) as date_month
  , date_trunc('week', c.date_day)  as date_week
  , c.date_day                      as date_day
  , date_part(year, c.date_day)     as year
  , date_part(quarter, c.date_day)  as quarter
  , date_part(month, c.date_day)    as month
  , to_char(c.date_day, 'month')    as month_name
  , to_char(c.date_day, 'W')        as week_of_month
  , date_part(week, c.date_day)     as week_of_year
  , date_part(day, c.date_day)      as day
  , to_char(c.date_day, 'day')      as day_name
  , date_part(dayofweek, c.date_day)
                                    as day_of_week
  , date_part(dayofyear, c.date_day)
                                    as day_of_year
from calendar c
