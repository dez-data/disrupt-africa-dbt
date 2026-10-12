select deal_id, startup_name, amount_usd
from {{ ref('stg_deals') }}
where amount_usd <= 0