import joblib
import json
import pandas as pd
from src.metrics import evaluate

model = joblib.load("/opt/ml/processing/model/model.joblib")
df = pd.read_csv("/opt/ml/processing/input/test.csv")

X = df.drop("churn", axis=1)
y = df["churn"]

pred = model.predict(X)
acc = evaluate(y, pred)

with open("/opt/ml/processing/output/metrics.json", "w") as f:
    json.dump({"accuracy": acc}, f)
