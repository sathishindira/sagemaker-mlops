import os

import time

import sagemaker

from sagemaker.workflow.pipeline import Pipeline

from sagemaker.sklearn.processing import SKLearnProcessor

from sagemaker.workflow.steps import ProcessingStep, TrainingStep

from sagemaker.processing import ProcessingInput, ProcessingOutput

from sagemaker.estimator import Estimator

from sagemaker.workflow.parameters import ParameterString

from sagemaker.session import Session

from sagemaker.inputs import TrainingInput

import boto3

region  = 'us-east-1'

bucket = 'mlops-learning-sathish'

role = 'arn:aws:iam::805702559038:role/Sagemaker_Exec'

s3_uri = ParameterString(
    name="InputDataS3Uri",
    default_value=f"s3://{bucket}/data/creditcard.csv"
)

boto3_session = boto3.Session(aws_access_key_id=secret_value_0,aws_secret_access_key=secret_value_1,region_name=region)

sm_client = boto3_session.client('sagemaker',region_name=region)

sm_runtime_client = boto3_session.client('sagemaker-runtime',region_name=region)

session = sagemaker.session.Session(boto_session = boto3_session, sagemaker_client =  sm_client, sagemaker_runtime_client = sm_runtime_client, default_bucket=bucket)

processor = SKLearnProcessor(framework_version="1.2-1", 
                 role= role, 
                 instance_count=1,
                 instance_type="ml.m5.xlarge",
                 sagemaker_session=session)

processing = ProcessingStep(name="Sklearn-Preprocessing",
                            processor=processor,
                            display_name="processing",
                            description="Download the dataset and Split into Train and Test Dataset",
                            inputs=[ProcessingInput(source=s3_uri,destination='/opt/ml/processing/input')],
                            outputs=[ProcessingOutput(output_name="train", source="/opt/ml/processing/output/train"),
                                    ProcessingOutput(output_name="test", source="/opt/ml/processing/output/test")],
                            code='/kaggle/working/processing.py',
                            job_arguments=[
                            "--input", "/opt/ml/processing/input/creditcard.csv",   # or your actual filename
                            "--output","/opt/ml/processing/output"])


train_image = sagemaker.image_uris.retrieve(framework='xgboost', region=region, version='1.5-1')

est = Estimator( image_uri=train_image,
        role=role,
        instance_count= 1,
        instance_type="ml.m5.xlarge",
        input_mode='File',
        base_job_name='fraud-train',
        sagemaker_session=session )

hyper = est.set_hyperparameters(objective='binary:logistic', num_round=100)

training = TrainingStep(name="Sagemaker_Training_Mlops", 
                        estimator=est,
                        display_name="Sagemaker_Training_Mlops",
                        description="Sagemaker_Training_Mlops_learning by doing",
                        inputs={'train': TrainingInput(s3_data=processing.properties.ProcessingOutputConfig.Outputs['train'].S3Output.S3Uri,content_type="text/csv")},
                        depends_on= [processing])

pipeline = Pipeline(name="Iris-ML-Pipeline",sagemaker_session=session, steps =[processing,training],parameters=[s3_uri])

pipeline.upsert(role_arn=role, description="Iris-ML-Pipeline with Sagemaker")

execution = pipeline.start() 

print("Execution ARN:", execution.arn)
con = "True"

while con=="True":

    desc = session.sagemaker_client.describe_pipeline_execution(
        PipelineExecutionArn=execution.arn
    )

    status = desc["PipelineExecutionStatus"]

    print("Status:", desc["PipelineExecutionStatus"])
    
    steps = session.sagemaker_client.list_pipeline_execution_steps(
        PipelineExecutionArn=execution.arn
    )
    if status == "Executing":
        con = "True"        
    else:
        con = "False"
    time.sleep(60)
if status == "Failed":
    print("FailureReason:", desc.get("FailureReason"))
    print("Steps:", steps)
elif status == "Succeeded":
    print("Reason: Success")
    print("Steps:", steps)

