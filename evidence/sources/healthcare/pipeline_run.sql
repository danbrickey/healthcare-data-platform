select
    strftime(
        (metadata->>'generated_at')::timestamp - interval '7 hours',
        '%b %d, %Y %I:%M %p'
    ) || ' MST' as last_run_at,
    metadata->>'dbt_version' as dbt_version,
    metadata->>'elapsed_time' as elapsed_seconds,
    len(results) as total_results
from read_json_auto('../dbt/target/run_results.json')
