import pandas as pd
import joblib
from src.model import build_model
from src.trainer import train

df = pd.read_csv("/opt/ml/input/data/train/processed.csv")
X = df.drop("churn", axis=1)
y = df["churn"]

model = train(build_model(), X, y)
joblib.dump(model, "/opt/ml/model/model.joblib")
