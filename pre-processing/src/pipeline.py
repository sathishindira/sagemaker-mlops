from .clean import clean_data
from .encode import encode_features

def run_pipeline(df):
    df = clean_data(df)
    df = encode_features(df)
    return df
