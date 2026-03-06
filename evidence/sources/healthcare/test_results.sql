select
    r.status,
    case
        when r.unique_id like 'test.%' then 'test'
        when r.unique_id like 'model.%' then 'model'
        else split_part(r.unique_id, '.', 1)
    end as resource_type,
    r.unique_id,
    r.execution_time,
    r.message
from read_json_auto('../dbt/target/run_results.json'),
unnest(results) as t(r)
