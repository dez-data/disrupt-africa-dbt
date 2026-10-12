import os
import re
from pathlib import Path

import pandas as pd
from sqlalchemy import create_engine, inspect, text
from sqlalchemy.engine import URL

COLS = ["startup", "location", "sector", "month", "amount_usd", "investors",
        "stage", "debt_equity", "female_cofounder", "female_ceo",
        "year_launched", "accelerator", "source_url"]

engine = create_engine(URL.create(
    "postgresql+psycopg2",
    username=os.environ["PGUSER"],
    password=os.environ["PGPASSWORD"],
    host="localhost", port=5432, database="disrupt_africa",
))

def read_file(path: Path) -> pd.DataFrame:
    df = pd.read_excel(path, header=0, dtype=str)
    df.columns = [re.sub(r"[^a-z0-9]+", "_", str(c).strip().lower()).strip("_")
                  for c in df.columns]
    missing = [c for c in COLS if c not in df.columns]
    if missing:
        raise ValueError(f"{path.name} is missing columns: {missing}")
    df = df[COLS]
    # group headers ("Fintech") and blank rows have nothing outside column A
    df = df[df.drop(columns="startup").notna().any(axis=1)].copy()
    df = df.apply(lambda s: s.str.strip())
    df["report_year"] = int(re.search(r"(20\d{2})", path.name).group(1))
    df["source_file"] = path.name
    return df.reset_index(drop=True)

for path in sorted(Path("data").glob("*.xlsx")):
    if path.name.startswith("~$"):
        continue
    df = read_file(path)
    if inspect(engine).has_table("deals", schema="raw"):
        with engine.begin() as conn:  # idempotent re-runs
            conn.execute(text("DELETE FROM raw.deals WHERE source_file = :f"),
                         {"f": path.name})
    df.to_sql("deals", engine, schema="raw", if_exists="append", index=False)
    print(f"{path.name}: loaded {len(df)} rows")