with raw_deals as (
    select * from {{ source('raw', 'deals') }}
)

select 'country' as field, lower(trim(location)) as raw_value
from raw_deals
where nullif(trim(location), '') is not null
  and lower(trim(location)) not in (select raw_value from {{ ref('country_map') }})

union all

select 'sector', lower(trim(sector))
from raw_deals
where nullif(trim(sector), '') is not null
  and lower(trim(sector)) not in (select raw_value from {{ ref('sector_map') }})

union all

select 'stage', lower(trim(stage))
from raw_deals
where nullif(trim(stage), '') is not null
  and lower(trim(stage)) not in (select raw_value from {{ ref('stage_map') }})

union all

select 'month', lower(trim(split_part(month, '+', 1)))
from raw_deals
where nullif(trim(month), '') is not null
  and lower(trim(split_part(month, '+', 1))) not in (select raw_value from {{ ref('month_map') }})