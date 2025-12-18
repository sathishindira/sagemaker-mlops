import os
import argparse
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler, LabelEncoder


def preprocess(local_input, local_output):

    df = pd.read_csv(local_input)
    df_processed = df.copy()
    df_processed['Churn'] = (df_processed['Churn?'] == 'True.').astype(int)
    df_processed.drop('Churn?', axis=1, inplace=True)
    df_processed.drop('Phone', axis=1, inplace=True)  # Remove phone numbers

    # Encode categorical variables
    categorical_cols = ['State', "Int'l Plan", 'VMail Plan']
    label_encoders = {}
    for col in categorical_cols:
        le = LabelEncoder()
        df_processed[col] = le.fit_transform(df_processed[col])
        label_encoders[col] = le

    # 🚀 Feature engineering: Create power features
    df_processed['Total_Charge'] = (df_processed['Day Charge'] + 
                                df_processed['Eve Charge'] + 
                                df_processed['Night Charge'] + 
                                df_processed['Intl Charge'])

    df_processed['Avg_Charge_Per_Min'] = df_processed['Total_Charge'] / (
        df_processed['Day Mins'] + df_processed['Eve Mins'] + 
        df_processed['Night Mins'] + df_processed['Intl Mins'] + 1e-8)

    df_processed['High_Service_Calls'] = (df_processed['CustServ Calls'] >= 4).astype(int)

    print('✅ Data preprocessing completed!')
    print(f'📊 Final dataset: {df_processed.shape[0]:,} customers, {df_processed.shape[1]} features')
    print(f'🎯 Target distribution: {df_processed["Churn"].mean():.1%} churn rate')

    # 🎯 Prepare for model training
    X = df_processed.drop('Churn', axis=1)
    y = df_processed['Churn']

    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=2, stratify=y
    )

    scaler = StandardScaler()
    X_train_scaled = scaler.fit_transform(X_train)
    X_test_scaled = scaler.transform(X_test)

    print(f'🎯 Training set: {X_train.shape[0]:,} customers')
    print(f'🎯 Test set: {X_test.shape[0]:,} customers')

    os.makedirs(local_output, exist_ok=True)
    X_train_scaled.to_csv(os.path.join(local_output, "train.csv"), index=False)
    X_test_scaled.to_csv(os.path.join(local_output, "test.csv"), index=False)

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", type=str, help="local input csv path")
    parser.add_argument("--output", type=str, help="local output folder")
    args = parser.parse_args()
    preprocess(args.input, args.output)