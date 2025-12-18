import pandas as pd
from preprocessing.src.pipeline import run_pipeline

def test_pipeline_removes_nulls():
    df = pd.DataFrame({"gender": ["M", None], "churn": [1, 0]})
    out = run_pipeline(df)
    assert out.isnull().sum().sum() == 0
