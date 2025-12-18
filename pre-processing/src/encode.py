from sklearn.preprocessing import LabelEncoder

def encode_features(df):
    encoder = LabelEncoder()
    df["gender"] = encoder.fit_transform(df["gender"])
    return df
