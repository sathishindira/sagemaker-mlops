# 📥 Load our customer intelligence database
import boto3
import os
import pandas as pd

session = boto3.Session()
aws_region = session.region_name or 'us-east-1'

s3 = boto3.client('s3')

# Create data directory if it doesn't exist
os.makedirs('data/raw', exist_ok=True)

s3.download_file(
    f'sagemaker-example-files-prod-{aws_region}',
    'datasets/tabular/synthetic/churn.txt',
    'data/raw/churn.txt'
)

df = pd.read_csv('data/raw/churn.txt')

print('🎯 Customer Database Loaded!')
print(f'📊 We have {df.shape[0]:,} customers with {df.shape[1]} data points each')
print(f'💾 Total data points: {df.shape[0] * df.shape[1]:,}')

# 🔍 First glimpse at our customers
print('\n👥 Meet our first 5 customers:')
df.head()