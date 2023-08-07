{% macro sanitize_cuit(cuit_column) %}
  replace(ltrim({{ cuit_column }}, '0'), '-', '')
{% endmacro %}
