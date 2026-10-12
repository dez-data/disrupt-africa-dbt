import re
import pandas as pd
from pathlib import Path

EXPECTED = ["startup", "location", "sector", "month", "amount_usd", "investors",
            "stage", "debt_equity", "female_cofounder", "female_ceo",
            "year_launched", "accelerator", "source_url"]

for f in sorted(Path("data").glob("*.xlsx")):
    xl = pd.ExcelFile(f)
    print(f"\n=== {f.name} | sheets: {xl.sheet_names} ===")
    for sheet in xl.sheet_names:
        df = xl.parse(sheet, header=0, dtype=str)
        cols = [re.sub(r"[^a-z0-9]+", "_", str(c).strip().lower()).strip("_")
                for c in df.columns]
        print(f"\n--- sheet: {sheet} | rows: {len(df)} | columns: {len(cols)} ---")
        print("missing:", [c for c in EXPECTED if c not in cols])
        print("extra:  ", [c for c in cols if c not in EXPECTED])
        print(df.head(5).to_string())