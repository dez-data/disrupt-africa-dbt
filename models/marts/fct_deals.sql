select
    d.deal_id,
    co.company_id,
    c.country_id,
    s.sector_id,
    d.deal_month,
    d.stage,
    d.stage_order,
    d.funding_type,
    d.amount_usd,
    d.has_disclosed_amount,
    d.is_multi_month,
    d.investors,
    d.source_url,
    d.report_year
from {{ ref('stg_deals') }} d
left join {{ ref('dim_company') }} co
    on d.startup_name = co.startup_name and d.country = co.country
left join {{ ref('dim_country') }} c
    on d.country = c.country
left join {{ ref('dim_sector') }} s
    on d.sector = s.sector