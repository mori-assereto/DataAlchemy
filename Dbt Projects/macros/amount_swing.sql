{% macro amount_swing(amount,previous_amount) -%}

  case
        when {{ amount}} - {{ previous_amount }} > 0
          then 'increase'
        when {{ amount}} - {{ previous_amount }} = 0
          and  {{ amount}} > 0
          and {{ previous_amount }} > 0
          then 'equal'
        when {{ amount}} - {{ previous_amount }} < 0
          then 'decrease'
        when {{ amount}} = 0 and {{ previous_amount }} <> 0
          then 'no_amount_this_month'
        when {{ amount }} = 0 and {{ previous_amount }} = 0
          then 'no_amount_both_months'
  end

{%- endmacro %}
