{% macro core_action_account_type(quantity) %}

case
  when {{ quantity }} between 0 and 4
                        then 'at_risk'

  when {{ quantity }} between 5 and 9
                        then 'casual'

  when {{ quantity }} between 10 and 19
                        then 'core'

  when {{ quantity }} > 19
                        then 'power'

  end

{% endmacro %}
