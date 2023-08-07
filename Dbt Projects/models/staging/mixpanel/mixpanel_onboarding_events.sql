{% set onboarding_events_name = (var('onboarding_events') | map(attribute='column_name')) %}
{% set onboarding_events_mixpanel = (var('onboarding_events') | map(attribute='mixpanel_name')) %}
{% set onboarding_events = var('onboarding_events') %}


select
  subscription_id
  , account_id
  , case
      {%  for element in onboarding_events  %}
        {% if element['mixpanel_name'] is not none %}
          when event= '{{ element['mixpanel_name'] }}' then '{{ element['column_name'] }}'
        {% endif %}
      {% endfor %}
    end as onboarding_event
  , min(time) as event_time
  from
    {{ source('mixpanel', 'mixpanel_export') }}
 where
    {% for onboarding_events_original in onboarding_events_mixpanel %}
      {% if onboarding_events_original is not none %}
        (event = '{{ onboarding_events_original }}' ) {{ 'or' if not loop.last }}
      {% endif %}
    {% endfor %}
  group by
    1, 2, 3
