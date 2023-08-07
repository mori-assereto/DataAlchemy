{% macro tickets_lifetime_category(lifetime) %}



  case
        when {{ lifetime }} < 8
          then '7'
        when  {{ lifetime }} between 8 and 15
            then '7-30'
        when {{ lifetime }} between 16 and 30
            then '30-60'
        when {{ lifetime }} > 60
            then '60'
  end

{% endmacro %}
