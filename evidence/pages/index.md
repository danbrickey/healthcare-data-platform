---
title: Healthcare Data Platform
queries:
  - patient_summary: healthcare.patient_summary
  - encounter_metrics: healthcare.encounter_metrics
  - pipeline_run: healthcare.pipeline_run
  - test_summary: healthcare.test_summary
  - test_results: healthcare.test_results
---

```sql patient_summary
select * from healthcare.patient_summary
```

```sql encounter_metrics
select * from healthcare.encounter_metrics
```

```sql pipeline_run
select * from healthcare.pipeline_run
```

```sql test_summary
select * from healthcare.test_summary
```

```sql test_results
select * from healthcare.test_results
```

```sql tests_only
select * from healthcare.test_summary where resource_type = 'test'
```

```sql models_only
select * from healthcare.test_summary where resource_type = 'model'
```

```sql patient_count
select count(*) as total_patients from healthcare.patient_summary
```

```sql gender_dist
select gender, count(*) as patient_count
from healthcare.patient_summary
group by gender
```

```sql race_dist
select race, count(*) as patient_count
from healthcare.patient_summary
group by race
order by patient_count desc
```

## Data Health

<Alert status="info">
    Pipeline last run: <Value data={pipeline_run} column=last_run_at /> — dbt v<Value data={pipeline_run} column=dbt_version /> — <Value data={pipeline_run} column=total_results /> results in <Value data={pipeline_run} column=elapsed_seconds fmt=num2 />s
</Alert>

<Grid cols=4>
    <BigValue
        data={tests_only}
        value=result_count
        agg=sum
        title="Tests Passed"
    />
    <BigValue
        data={models_only}
        value=result_count
        agg=sum
        title="Models Built"
    />
    <BigValue
        data={pipeline_run}
        value=elapsed_seconds
        title="Build Time (s)"
        fmt=num1
    />
    <BigValue
        data={pipeline_run}
        value=last_run_at
        title="Last Run"
    />
</Grid>

<Grid cols=2>
    <BarChart
        data={test_summary}
        x=resource_type
        y=result_count
        series=status
        title="Results by Type"
        type=stacked
    />
    <DataTable
        data={test_summary}
        rows=all
    >
        <Column id=resource_type title="Type" />
        <Column id=status title="Status" />
        <Column id=result_count title="Count" fmt=num0 />
    </DataTable>
</Grid>

---

## Population Overview

<Grid cols=3>
    <BigValue
        data={patient_count}
        value=total_patients
        title="Total Patients"
    />
    <BigValue
        data={patient_summary}
        value=total_encounters
        agg=sum
        title="Total Encounters"
    />
    <BigValue
        data={patient_summary}
        value=total_claim_cost
        agg=sum
        fmt=usd
        title="Total Claims"
    />
</Grid>

## Encounters by Class

<BarChart
    data={encounter_metrics}
    x=encounter_class
    y=encounter_count
    title="Encounter Volume by Class"
    sort=false
/>

<DataTable
    data={encounter_metrics}
    rows=all
>
    <Column id=encounter_class title="Class" />
    <Column id=encounter_count title="Count" fmt=num0 />
    <Column id=unique_patients title="Patients" fmt=num0 />
    <Column id=avg_claim_cost title="Avg Cost" fmt=usd />
    <Column id=avg_payer_coverage title="Avg Payer" fmt=usd />
    <Column id=avg_out_of_pocket_cost title="Avg OOP" fmt=usd />
</DataTable>

## Cost Analysis

<BarChart
    data={encounter_metrics}
    x=encounter_class
    y={["total_claim_cost", "total_payer_coverage"]}
    title="Total Cost vs Payer Coverage by Encounter Class"
    type=grouped
    sort=false
/>

## Patient Demographics

<Grid cols=2>
    <BarChart
        data={gender_dist}
        x=gender
        y=patient_count
        title="Patients by Gender"
    />
    <BarChart
        data={race_dist}
        x=race
        y=patient_count
        title="Patients by Race"
        swapXY=true
    />
</Grid>
