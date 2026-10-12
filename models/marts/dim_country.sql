select
    md5(country) as country_id,
    country,
    region
from (
    select distinct country, region
    from {{ ref('stg_deals') }}
) c