{% macro rate_formula(total,quantity) -%}

  case
        when {{ total }}::float <> 0
          then {{ quantity }}::float / {{ total }}::float
        when {{ total }}::float  = 0
          then 0
        else 0
  end

{%- endmacro %}
