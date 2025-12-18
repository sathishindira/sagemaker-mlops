import pandas as pd
from sagemaker.sklearn.processing import SKLearnProcessor
from sagemaker.processing import ProcessingInput, ProcessingOutput
from sagemaker.workflow.steps import ProcessingStep
from sagemaker.workflow.parameters import ParameterString, ParameterInteger
import boto3
import sagemaker

region = 'us-east-1'
bucket = 'sagemaker-mlops-sathish-01'
role = 'arn:aws:iam::805702559038:role/Sagemaker_Exec'

def main():
    sagemaker_session = sagemaker.session.Session(boto_session=boto3.Session(region_name=region))
    sm_client = sagemaker_session.sagemaker_client

    # Pipeline parameters
    input_s3_uri = ParameterString(name="InputDataS3Uri", default_value=f"s3://{bucket}/churn.txt")
    processing_instance_count = ParameterInteger(name="ProcessingInstanceCount", default_value=1)

    # SKLearn processor (uses sagemaker sklearn image)
    sklearn_processor = SKLearnProcessor(
        framework_version="1.2-1",
        role=role,
        instance_type="ml.m5.xlarge",
        instance_count=1,
        base_job_name="churn-preprocess",
        sagemaker_session=sagemaker_session,
    )

    sklearn_processor.run(
        inputs=[
            ProcessingInput(source=input_s3_uri, destination="/opt/ml/processing/input")
        ],
        outputs=[
            ProcessingOutput(output_name="train", source="/opt/ml/processing/output/train"),
            ProcessingOutput(output_name="test", source="/opt/ml/processing/output/test")
        ],
        code="src/preprocess.py"
        wait=True,
        logs=True
    )

if __name__ == "__main__":
    main()