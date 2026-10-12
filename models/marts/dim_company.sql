select
    md5(concat_ws('|', startup_name, country))  as company_id,
    startup_name,
    country,
    min(year_launched)                          as year_launched,
    bool_or(has_female_cofounder)               as has_female_cofounder,
    bool_or(has_female_ceo)                     as has_female_ceo,
    bool_or(went_through_accelerator)           as went_through_accelerator
from {{ ref('stg_deals') }}
group by startup_name, country