{% macro core_action_duration(category,
                              has_setup_moment,
                              setup_date,
                              api_setup_date,
                              core_action_date) %}



    case
      when  {{ category }} = 'integrated'
          and {{ has_setup_moment }}
              then datediff (day, {{ api_setup_date }} , {{ core_action_date }} )
      when  {{ category }} <> 'integrated'
        and {{ has_setup_moment }}
          then datediff (day, {{ setup_date }} , {{ core_action_date }} )
      else null
    end

{% endmacro %}
