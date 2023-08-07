{% macro normalize_boolean_string(column) %}
  case
      when {{ column }} IN ('f','false') then 'false'
      when {{ column }} IN ('t','true') then 'true'
      else {{ column }}
  end
{% endmacro %}
