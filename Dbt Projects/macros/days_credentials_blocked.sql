{% macro days_credentials_blocked(credential_date_day,
                                  state,
                                  product) %}

{% set card = var('products')['card'] %}

    case
      when  {{ product }} = '{{ card["name"] }}'
          and {{ state }} <> 'canceled'
          and ( datediff(day, {{ credential_date_day }}, current_date) <= 0 )
            then 0

      when  {{ product }} = '{{ card["name"] }}'
          and {{ state }} <> 'canceled'
          and ( datediff(day, {{ credential_date_day }}, current_date) > 0 )
            then datediff(day, {{ credential_date_day }}, current_date)

      when {{ product }} = '{{ card["name"] }}'
          and {{ state }} = 'canceled'
            then null

      else null
    end

{% endmacro %}
