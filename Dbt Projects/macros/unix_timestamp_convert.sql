{% macro unix_timestamp_convert(date_field) %}

(timestamp 'epoch' +
  cast({{ date_field }} AS bigint)/1000 * interval '1 second')
  - interval '3 hour'

{% endmacro %}
