{% macro job_duration(is_over,
                      time_unit,
                      first_date,
                      second_date) %}

  case
      when {{ is_over }}
        then datediff('{{ time_unit }}', {{ first_date }}, {{ second_date }})
  end

{% endmacro %}
