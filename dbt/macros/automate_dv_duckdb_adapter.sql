{#
    AutomateDV DuckDB Adapter Macros
    
    This file provides DuckDB-specific implementations for AutomateDV macros.
    DuckDB syntax is similar to PostgreSQL but has its own specific functions.
    
    Reference: https://duckdb.org/docs/sql/functions/overview
#}

{#- ============================================================ -#}
{#- ESCAPE CHARACTERS                                            -#}
{#- ============================================================ -#}

{%- macro duckdb__get_escape_characters() %}
    {#- DuckDB uses double quotes for identifier escaping like PostgreSQL -#}
    {%- do return (('"', '"')) -%}
{%- endmacro %}


{#- ============================================================ -#}
{#- DATA TYPES                                                    -#}
{#- ============================================================ -#}

{%- macro duckdb__type_binary(for_dbt_compare=false) -%}
    {#- DuckDB uses BLOB for binary data -#}
    BLOB
{%- endmacro -%}

{%- macro duckdb__type_timestamp(for_dbt_compare=false) -%}
    TIMESTAMP
{%- endmacro -%}

{%- macro duckdb__type_string(is_hash=false, char_length=255) -%}
    {#- DuckDB uses VARCHAR for all string types -#}
    VARCHAR
{%- endmacro -%}


{#- ============================================================ -#}
{#- HASH ALGORITHMS                                               -#}
{#- ============================================================ -#}

{% macro duckdb__hash_alg_md5() -%}
    {#- DuckDB md5() returns a VARCHAR hex string, we keep it as string for simplicity -#}
    {#- Use UPPER for consistency with other platforms -#}
    {% do return("UPPER(MD5([HASH_STRING_PLACEHOLDER]))") %}
{% endmacro %}

{% macro duckdb__hash_alg_sha256() -%}
    {#- DuckDB sha256() returns a VARCHAR hex string -#}
    {% do return("UPPER(SHA256([HASH_STRING_PLACEHOLDER]))") %}
{% endmacro %}

{% macro duckdb__hash_alg_sha1() -%}
    {#- DuckDB does not have a built-in SHA1 function, fall back to MD5 with warning -#}
    {%- do exceptions.warn("Configured hash (SHA-1) is not supported on DuckDB. Defaulting to hash 'MD5', alternatively configure your hash as 'SHA' for SHA256 hashing.") -%}
    {{ automate_dv.hash_alg_md5() }}
{% endmacro %}


{#- ============================================================ -#}
{#- CASTING                                                       -#}
{#- ============================================================ -#}

{%- macro duckdb__cast_binary(column_str, alias=none, quote=true) -%}
    {#- For DuckDB, we keep hashes as strings (VARCHAR) for easier querying -#}
    {%- if quote -%}
        CAST('{{ column_str }}' AS VARCHAR)
    {%- else -%}
        CAST({{ column_str }} AS VARCHAR)
    {%- endif -%}

    {%- if alias %} AS {{ alias }} {%- endif -%}
{%- endmacro -%}


{#- ============================================================ -#}
{#- DATE/TIME FUNCTIONS                                          -#}
{#- ============================================================ -#}

{% macro duckdb__dateadd(datepart, interval, from_date_or_timestamp) %}
    {#- DuckDB uses date arithmetic with INTERVAL -#}
    {{ from_date_or_timestamp }} + INTERVAL '{{ interval }}' {{ datepart }}
{% endmacro %}

{% macro duckdb__max_datetime() %}
    {#- Maximum timestamp value for DuckDB -#}
    TIMESTAMP '9999-12-31 23:59:59.999999'
{% endmacro %}


{#- ============================================================ -#}
{#- HASH FUNCTION (delegates to default)                          -#}
{#- ============================================================ -#}

{%- macro duckdb__hash(columns, alias, is_hashdiff, columns_to_escape) -%}
    {{ automate_dv.default__hash(columns=columns, alias=alias, is_hashdiff=is_hashdiff, columns_to_escape=columns_to_escape) }}
{%- endmacro -%}


{#- ============================================================ -#}
{#- CONCAT_WS (string concatenation)                              -#}
{#- ============================================================ -#}

{% macro duckdb__concat_ws(string_list, separator='||') %}
    {#- DuckDB supports CONCAT_WS but we use || for consistency -#}
    {{ string_list | join(' ' ~ separator ~ ' ') }}
{% endmacro %}


{#- ============================================================ -#}
{#- DATE CASTING                                                  -#}
{#- ============================================================ -#}

{%- macro duckdb__cast_date(column_str, as_string=false, alias=none) -%}
    {#- DuckDB uses CAST for date conversion -#}
    {%- if as_string -%}
        CAST('{{ column_str }}' AS DATE)
    {%- else -%}
        CAST({{ column_str }} AS DATE)
    {%- endif -%}

    {%- if alias %} AS {{ alias }} {%- endif %}
{%- endmacro -%}

{%- macro duckdb__cast_datetime(column_str, as_string=false, alias=none, date_type=none) -%}
    {#- DuckDB uses CAST for timestamp conversion -#}
    CAST({{ column_str }} AS TIMESTAMP)

    {%- if alias %} AS {{ alias }} {%- endif %}
{%- endmacro -%}


{#- ============================================================ -#}
{#- GHOST RECORDS                                                 -#}
{#- ============================================================ -#}

{%- macro duckdb__binary_ghost() -%}
    {#- Ghost record for binary/hash columns -#}
    '0000000000000000'
{%- endmacro -%}

{%- macro duckdb__date_ghost() -%}
    {#- Ghost record for date columns -#}
    CAST('1900-01-01' AS DATE)
{%- endmacro -%}
