{% macro collect_file_date(created_at) -%}

  case
        when to_char({{ created_at }}, 'day') in ('monday','sunday')
          then dateadd(day,4,{{ created_at }})
        when to_char({{ created_at }}, 'day') in ('tuesday','wednesday','thursday','friday')
          then dateadd(day,6,{{ created_at }})
        when to_char({{ created_at }}, 'day') = 'saturday'
            then dateadd(day,5,{{ created_at }})
  end

{%- endmacro %}
