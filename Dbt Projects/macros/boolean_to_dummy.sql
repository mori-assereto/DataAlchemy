{% macro boolean_to_dummy(column) %}
  case
      when {{ column }} IN ('f','false') then 0
      when {{ column }} IN ('t','true') then 1
  end
{% endmacro %}
