{% macro map_enum_to_strings(column, dict, default_value) -%}
  case
  {% for e, str in dict.items() %}

    when {{ column }} = {{ e }} then '{{ str }}'

  {% endfor %}

    when {{ column }} is null then null

  {% if default_value is not none %}

    else '{{ default_value }}'

  {% endif %}

  end
{%- endmacro %}
