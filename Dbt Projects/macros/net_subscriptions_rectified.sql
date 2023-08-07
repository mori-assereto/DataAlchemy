{% macro net_subscriptions_rectified( active_subscriptions,
                                      subscription_lost,
                                      trx_subscriptions) -%}

  case
        when
          {{ trx_subscriptions }} - {{ active_subscriptions }} > {{ subscription_lost }} + 5
          then {{ trx_subscriptions }} - {{ subscription_lost }}
        when
          {{ trx_subscriptions }} - {{ active_subscriptions }} < {{ subscription_lost }} + 5
          then  {{ trx_subscriptions }}
        when {{ trx_subscriptions }} - {{ active_subscriptions }} = 0
          then {{ active_subscriptions }}
  end

{%- endmacro %}
