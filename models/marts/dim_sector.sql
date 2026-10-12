select
    md5(sector) as sector_id,
    sector
from (
    select distinct sector
    from {{ ref('stg_deals') }}
) s