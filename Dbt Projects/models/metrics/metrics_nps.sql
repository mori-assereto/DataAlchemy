

with

"accounts_with_enterprise_flag" as (

  select
      "accounts"."id"
    , {{ parse_boolean_string('enterprise') }}
          as "enterprise"
  from
    {{ source('platform', 'accounts')}} "accounts"

)

, "platform_nps" as (

  select
      "platform_nps"."id"
    , "platform_nps"."answer_date" as "answered_at"
    , "platform_nps"."comment"
    , "platform_nps"."score"
    , "platform_nps"."is_promoter"
    , "platform_nps"."is_detractor"
    , "platform_nps"."is_neutral"
    , "platform_nps"."user_id"
    , "platform_nps"."account_id"
    , "platform_nps"."subscription_id"
    , "platform_nps"."product"
    , "platform_nps"."country"
  from
    {{ ref('platform_survey_responses') }} "platform_nps"
  where
    "platform_nps"."status" = 'finished'

)

, "appcues_nps" as (

  select
      null as "id"
    , "appcues_nps"."answered_at"
    , "appcues_nps"."comment"
    , "appcues_nps"."score"
    , "appcues_nps"."is_promoter"
    , "appcues_nps"."is_detractor"
    , "appcues_nps"."is_neutral"
    , "appcues_nps"."user_id"
    , "appcues_nps"."account_id"
    , "appcues_nps"."subscription_id"
    , "appcues_nps"."product"
    , "appcues_nps"."country"
  from
    {{ ref('appcues_nps') }} "appcues_nps"
  where
    "appcues_nps"."score" is not null

)

, "nps_full_base" as (

  select * from "platform_nps"
  union all
  select * from "appcues_nps"

)

, "subscriptions" as (

  select
      "subscriptions"."id"
    , "subscriptions"."initial_billing"
    , "subscriptions"."origin"
  from
    {{ ref('platform_subscriptions') }} "subscriptions"

)

select
    "nps_full_base".*
  , "accounts_with_enterprise_flag"."enterprise"
  , lag("nps_full_base"."score") ignore nulls
          over (partition by "nps_full_base"."user_id","nps_full_base"."subscription_id"
                order by "nps_full_base"."answered_at")
          as "previous_nps"
from "nps_full_base"
left join "accounts_with_enterprise_flag"
  on "nps_full_base"."account_id" = "accounts_with_enterprise_flag"."id"
left join "subscriptions"
  on "subscriptions"."id" = "nps_full_base"."subscription_id"
