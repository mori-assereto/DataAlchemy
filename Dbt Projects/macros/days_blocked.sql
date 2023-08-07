{% macro days_blocked (credential_date_day, status, credential_blocked_at) %}

    case
      when {{ status }} = 'Ok'
        then 0

      when {{ status }} in ('Disabled', 'Deleted')
        then null

      when {{ status }} not in ('Ok', 'Disabled', 'Deleted')
        then datediff(day, coalesce({{ credential_date_day }}, {{ credential_blocked_at }} ), current_date)

    end

{% endmacro %}
