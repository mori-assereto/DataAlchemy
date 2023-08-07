{% macro calculate_bank_closing_date_diff(date_field, limit_date_field, timezone, hours_offset, days_offset) %}
    {{ limit_date_field }}::timestamp + interval '{{ hours_offset }}' - interval '{{ days_offset }}' - convert_timezone('UTC', '{{ timezone }}', {{ date_field }} )
{% endmacro %}
