{% set onboarding_events = var('onboarding_events') %}

with tickets_with_subscription as (

  select
    ticket_id
    , subscription_id
    , created_at
  from
    {{ ref('zendesk_tickets_with_subscription') }}

), subscriptions_with_onboarding_events as (

  select
    subscription_id
    , onboarding_event
    , event_time
  from
    {{ ref('mixpanel_subscriptions_with_onboarding_events') }}
)


select distinct
  t.subscription_id
  , ticket_id
  , last_value(onboarding_event) over (partition by t.subscription_id
                                        order by
                                        case
                                        {%  for element in onboarding_events  %}
                                            when onboarding_event='{{ element['column_name'] }}'
                                            then '{{ element['event_order'] }}'
                                        {% endfor %}
                                        end
                                        rows between unbounded preceding
                                        and unbounded following)
                                          as onboarding_stage
from tickets_with_subscription t
left join subscriptions_with_onboarding_events oe
  on t.subscription_id = oe.subscription_id
  and  oe.event_time < t.created_at
