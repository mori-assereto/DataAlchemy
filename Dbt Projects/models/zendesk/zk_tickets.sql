with

"tickets" as (

  select
    "tickets".*
  from
    {{ source ('zendesk', 'tickets') }} "tickets"

)

, "ticket_metrics" as (

  select
      "ticket_id"
    , "solved_at"
  from
    {{ source('zendesk', 'ticket_metrics') }} "ticket_metrics"

)

, "tickets_with_subscription" as (

  select
    "tickets_with_subscription".*
  from
    {{ ref('zendesk_tickets_with_subscription') }} "tickets_with_subscription"

)

, "tickets_with_zendesk_products" as (

  select
      "ticket_id"
    , "zendesk_product"
  from
    {{ ref('zendesk_tickets_with_zendesk_product') }} "tickets_with_zendesk_products"

)

, "tickets_onboarding" as (

  select
    "tickets_onboarding".*
  from
    {{ ref('zendesk_tickets_with_onboarding_events') }} "tickets_onboarding"

)

, "tickets_proactiveness" as (

  select
      "tickets_proactiveness"."ticket_id"
    , "tickets_proactiveness"."is_proactive"
  from
    {{ ref('zendesk_tickets_proactiveness') }} "tickets_proactiveness"

)

, "users_account" as (

  select
    "users_account".*
  from
    {{ ref('zendesk_users_with_account') }} "users_account"

)

, "derivations" as (

  select
    "derivations".*
  from
    {{ ref('zendesk_tickets_derivations') }} "derivations"

)

, "platform_accounts_with_initial_billing" as (

  select
      "platform_accounts_with_initial_billing"."account_id"
    , "platform_accounts_with_initial_billing"."initial_billing"
  from
    {{ ref('staging_platform_accounts_state') }} "platform_accounts_with_initial_billing"

)

, "tickets_with_jira_flag" as (

  select
      "tickets_custom_fields"."ticket_id"
    , coalesce("tickets_custom_fields"."value__boolean", false)
          as "has_jira"
  from
    {{ ref('zk_tickets_custom_fields') }} "tickets_custom_fields"
  where
    "tickets_custom_fields"."id" = '360038769134'

)

, "tickets_with_faltantes" as (

  select
      "tickets_custom_fields"."ticket_id"
    , coalesce("tickets_custom_fields"."value__boolean", false)
          as "is_faltantes"
  from
    {{ ref('zk_tickets_custom_fields') }} "tickets_custom_fields"
  where
    "tickets_custom_fields"."id" = '360046208954'

)

, "tickets_with_jira_values" as (

  select
    "tickets_with_jira_values".*
  from
    {{ ref('zendesk_tickets_with_jira_values') }} "tickets_with_jira_values"

)

, "tickets_with_subscription_state" as (

  select
    "tickets_with_subscription_state".*
  from
    {{ ref('zendesk_tickets_with_subscription_state') }} "tickets_with_subscription_state"

)

, "tickets_with_origin" as (

  select
      "tickets_with_origin"."ticket_id"
    , "tickets_with_origin"."origin"
  from
    {{ ref('zendesk_tickets_with_origin') }} "tickets_with_origin"

)

, "tickets_with_canceled_typification" as (

  select
      "tickets_with_canceled_typification"."ticket_id"
    , "tickets_with_canceled_typification"."canceled_typification"
  from
    {{ ref('zendesk_tickets_with_canceled_typification') }} "tickets_with_canceled_typification"

)

, "tickets_with_canceled_flag" as (

  select
      "tickets_custom_fields"."ticket_id"
    , coalesce("tickets_custom_fields"."value__boolean", false)
          as "has_canceled_flag"
  from
    {{ ref('zk_tickets_custom_fields') }} "tickets_custom_fields"
  where
    "tickets_custom_fields"."id" = '1260804998169'

)

, "tickets_with_scaling" as (

  select
      "tickets_with_scaling"."ticket_id"
    , "tickets_with_scaling"."scaling"
  from
    {{ ref('zendesk_tickets_with_scaling') }} "tickets_with_scaling"

)

, "tickets_with_product_scaling" as (

  select
      "tickets_with_product_scaling"."ticket_id"
    , "tickets_with_product_scaling"."product_scaling"
  from
    {{ ref('zendesk_tickets_with_product_scaling') }} "tickets_with_product_scaling"

)

, "tickets_with_tag_closed_by_merge" as (

  select
      "tickets_with_tag_closed_by_merge"."ticket_id"
    , "tickets_with_tag_closed_by_merge"."value"
  from
    {{ ref('zendesk_tickets_with_tag_closed_by_merge') }} "tickets_with_tag_closed_by_merge"

)

, "tickets_reopen" as (

  select
    "tickets_reopen"."ticket_id"
    , "tickets_reopen"."is_reopen"
  from
    {{ ref('zendesk_tickets_is_reopen') }} "tickets_reopen"

)

, "type_of_consulting" as (

  select
      "type_of_consulting"."ticket_id"
    , "type_of_consulting"."type_of_consulting"
  from
    {{ ref('zendesk_tickets_with_type_of_consulting') }} "type_of_consulting"
)

, "tickets_with_onboarding_flag" as (

  select
      "tickets_with_onboarding_flag"."ticket_id"
    , "tickets_with_onboarding_flag"."is_onboarding"
  from
    {{ ref('zendesk_tickets_with_onboarding_flag') }} "tickets_with_onboarding_flag"

)

select
    "tickets".*
  , "ticket_metrics"."solved_at"
  , "users_account"."platform_account_id"
  , datediff('days', "platform_accounts_with_initial_billing"."initial_billing", "tickets"."created_at") <= 30
                      as "is_within_first_30_days_as_client"
  , "tickets_with_subscription"."subscription_id"
  , "tickets_onboarding"."onboarding_stage"
  , {{ tickets_circle_categorize('"tickets"."ticket_form_id"') }}
                      as "ticket_circle"
  , {{ tickets_country('"tickets"."brand_id"') }}
                      as "country"
  , "tickets_with_zendesk_products"."zendesk_product"
  , {{ tickets_form_categorize('"tickets"."ticket_form_id"') }}
                      as "ticket_category"
  , {{ dbt_utils.star(from=ref('zendesk_tickets_derivations'),
                      except=['ticket_id', 'created_at', 'was_derived'],
                      relation_alias='derivations'
    ) }}
  , coalesce("derivations"."was_derived", false) as "was_derived"
  , "tickets_proactiveness"."is_proactive"
  , datediff(
      'days', "tickets"."created_at",
      coalesce("ticket_metrics"."solved_at", current_date)
    )
                                  as "lifetime_days"
  , "tickets_with_jira_flag"."has_jira"
  , "tickets_with_faltantes"."is_faltantes"
  , "tickets_with_jira_values"."jira_card_number"
  , "tickets_with_jira_values"."jira_status"
  , "tickets_with_jira_values"."jira_issue_type"
  , "tickets_with_jira_values"."jira_card_name"
  , "tickets_with_jira_values"."jira_card_created_at"
  , datediff( 'days',
              "tickets_with_jira_values"."jira_card_created_at",
              coalesce("ticket_metrics"."solved_at", current_date))
                                  as "lifetime_jira_card"
  , "tickets_with_subscription_state"."subscription_state"
  , "tickets_with_origin"."origin"
  , {{ tickets_category_group('"tickets"."group_id"') }}
                                as "category_group"
  , ("tickets_with_canceled_typification"."canceled_typification" is not null)
        as "has_canceled_typification"
  , "tickets_with_canceled_flag"."has_canceled_flag"
  , {{ tickets_lifetime_category ('"lifetime_days"') }}
        as "lifetime_category"
  , "tickets_with_scaling"."scaling"
  , "tickets_with_product_scaling"."product_scaling"
  , {{ tickets_has_achieve_sla ('"lifetime_days"',
                                '"tickets_with_scaling"."scaling"',
                                '"tickets_with_product_scaling"."product_scaling"',
                                '"tickets_with_zendesk_products"."zendesk_product"',
                                '"category_group"',
                                '"tickets"."created_at"') }}
                                as "has_achieve_sla"
  , "tickets"."status" in ('closed', 'solved') as "is_solved"
  , "tickets_with_scaling"."scaling" is not null as "has_scaling_flag"
  , "tickets_with_tag_closed_by_merge"."value" is not null as "is_closed_by_merge"
  , "tickets_reopen"."is_reopen"
  , {{ has_scaling_dependece ('"has_scaling_flag"',
                              '"tickets_with_scaling"."scaling"') }}
                                as "has_scaling_dependece"
  , "type_of_consulting"."type_of_consulting"
  , "tickets_with_onboarding_flag"."is_onboarding"
  , lag("tickets"."satisfaction_rating__score") ignore nulls
                    over (partition by "tickets"."requester_id"
                          order by "tickets"."created_at")
                                as "previous_score"
from
  "tickets"
left join "ticket_metrics"
  on "tickets"."id" = "ticket_metrics"."ticket_id"
left join "users_account"
  on "tickets"."requester_id" = "users_account"."zendesk_user_id"
left join "tickets_with_subscription"
  on "tickets"."id" = "tickets_with_subscription"."ticket_id"
left join "tickets_with_zendesk_products"
  on "tickets"."id" = "tickets_with_zendesk_products"."ticket_id"
left join "tickets_onboarding"
  on "tickets".id = "tickets_onboarding"."ticket_id"
left join "derivations"
  on "tickets"."id" = "derivations"."ticket_id"
left join "tickets_proactiveness"
  on "tickets"."id" = "tickets_proactiveness"."ticket_id"
left join "platform_accounts_with_initial_billing"
  on "users_account"."platform_account_id" = "platform_accounts_with_initial_billing"."account_id"
left join "tickets_with_jira_flag"
  on "tickets"."id" = "tickets_with_jira_flag"."ticket_id"
left join "tickets_with_faltantes"
  on "tickets"."id" = "tickets_with_faltantes"."ticket_id"
left join "tickets_with_jira_values"
  on "tickets"."id" = "tickets_with_jira_values"."ticket_id"
left join "tickets_with_subscription_state"
  on "tickets"."id" = "tickets_with_subscription_state"."ticket_id"
left join "tickets_with_origin"
  on "tickets"."id" = "tickets_with_origin"."ticket_id"
left join "tickets_with_canceled_typification"
  on "tickets"."id" = "tickets_with_canceled_typification"."ticket_id"
left join "tickets_with_canceled_flag"
  on "tickets"."id" = "tickets_with_canceled_flag"."ticket_id"
left join "tickets_with_scaling"
  on "tickets"."id" = "tickets_with_scaling"."ticket_id"
left join "tickets_with_product_scaling"
  on "tickets"."id" = "tickets_with_product_scaling"."ticket_id"
left join "tickets_with_tag_closed_by_merge"
  on "tickets"."id" = "tickets_with_tag_closed_by_merge"."ticket_id"
left join "tickets_reopen"
  on "tickets"."id" = "tickets_reopen"."ticket_id"
left join "type_of_consulting"
  on "tickets"."id" = "type_of_consulting"."ticket_id"
left join "tickets_with_onboarding_flag"
  on "tickets"."id" = "tickets_with_onboarding_flag"."ticket_id"
