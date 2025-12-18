from sagemaker.workflow.pipeline import Pipeline
from sagemaker.workflow.steps import ProcessingStep, TrainingStep
from sagemaker.workflow.model_step import RegisterModel

pipeline = Pipeline(
    name="churn-pipeline",
    steps=[
        preprocess_step,
        train_step,
        evaluate_step,
        register_step
    ]
)
