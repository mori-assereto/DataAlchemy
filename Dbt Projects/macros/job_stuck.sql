{% macro job_stuck( state,
                    last_runned_at,
                    last_enqueued_at) %}

  case
      when {{ state }} = 'running'
      and {{ last_runned_at }} < getdate() - interval '1 hour'
        then true
      when {{ state }} in ('enqueued', 'external_enqueued')
      and {{ last_enqueued_at }} < getdate() - interval '1 hour'
          then true
      else false
  end

{% endmacro %}
