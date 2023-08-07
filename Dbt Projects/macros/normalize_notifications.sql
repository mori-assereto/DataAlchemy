{% macro normalize_notifications(notification) -%}

      case
            when {{ notification }} = ''
              then 'false'
            else {{ notification }}
      end

{%- endmacro %}
