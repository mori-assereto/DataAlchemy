{% macro parsed_date_limit(payment_date) -%}
    payment_date::timestamp at time zone 'ARST' + interval '14 hours' - interval '1 day'
{%- endmacro %}
