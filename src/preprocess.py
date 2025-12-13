import pandas as pd
import argparse
import os


def preprocess(local_input, local_output):
    df = pd.read_csv(local_input)
    # Minimal preprocessing: drop columns if present
    if "Time" in df.columns:
        df = df.drop(columns=["Time"])

    label_col = "Class"
    df = df[[label_col] + [c for c in df.columns if c != label_col]]


    train = df.sample(frac=0.8, random_state=42)
    test = df.drop(train.index)

    
    os.makedirs(local_output, exist_ok=True)
    train.to_csv(os.path.join(local_output,"train", "train.csv"), index=False,header=False)
    test.to_csv(os.path.join(local_output,"test", "test.csv"), index=False,header=False)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", type=str, help="local input csv path")
    parser.add_argument("--output", type=str, help="local output folder")
    args = parser.parse_args()
    preprocess(args.input, args.output)