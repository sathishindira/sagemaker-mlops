import pandas as pd
from src.pipeline import run_pipeline

df = pd.read_csv("/opt/ml/processing/input/data.csv")
df = run_pipeline(df)
df.to_csv("/opt/ml/processing/output/processed.csv", index=False)
