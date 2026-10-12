with source as (

    select * from {{ source('raw', 'deals') }}

),

cleaned as (

    select
        nullif(trim(startup), '')                           as startup_name,
        lower(trim(location))                               as location_key,
        lower(trim(sector))                                 as sector_key,
        lower(trim(split_part(month, '+', 1)))              as month_key,
        month like '%+%'                                    as is_multi_month,
        nullif(trim(amount_usd), '')::numeric               as amount_usd,
        lower(trim(stage))                                  as stage_key,
        case lower(trim(debt_equity))
            when 'equity/debr' then 'Equity/debt'
            else nullif(trim(debt_equity), '')
        end                                                 as funding_type,
        case lower(trim(female_cofounder))
            when 'yes' then true when 'no' then false end   as has_female_cofounder,
        case lower(trim(female_ceo))
            when 'yes' then true when 'no' then false end   as has_female_ceo,
        case when trim(year_launched) ~ '^[0-9]{4}$'
            then trim(year_launched)::int end               as year_launched,
        case lower(trim(accelerator))
            when 'yes' then true when 'no' then false end   as went_through_accelerator,
        nullif(trim(investors), '')                         as investors,
        nullif(trim(source_url), '')                        as source_url,
        report_year::int as report_year,
        source_file
    from source

),

keyed as (

    select
        md5(concat_ws('|',
            coalesce(startup_name, ''),
            coalesce(location_key, ''),
            coalesce(month_key, ''),
            coalesce(amount_usd::text, ''),
            coalesce(stage_key, ''),
            report_year::text
        )) as deal_id,
        *
    from cleaned

),

deduped as (

    select
        *,
        row_number() over (
            partition by deal_id
            order by (source_url is null), source_url
        ) as rn
    from keyed

)

select
    d.deal_id,
    d.startup_name,
    c.country,
    c.region,
    s.sector,
    st.stage,
    st.stage_order,
    make_date(d.report_year, m.month_number, 1)  as deal_month,
    d.is_multi_month,
    d.amount_usd,
    d.amount_usd is not null                     as has_disclosed_amount,
    d.funding_type,
    d.has_female_cofounder,
    d.has_female_ceo,
    d.year_launched,
    d.went_through_accelerator,
    d.investors,
    d.source_url,
    d.report_year,
    d.source_file
from deduped d
left join {{ ref('country_map') }} c  on d.location_key = c.raw_value
left join {{ ref('sector_map') }}  s  on d.sector_key   = s.raw_value
left join {{ ref('stage_map') }}   st on d.stage_key    = st.raw_value
left join {{ ref('month_map') }}   m  on d.month_key    = m.raw_value
where d.rn = 1