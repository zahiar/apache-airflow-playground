from airflow.models.dag import DAG
from airflow.operators.dummy_operator import DummyOperator
from airflow.operators.python_operator import PythonOperator
from airflow.utils.dates import days_ago
from airflow.hooks.S3_hook import S3Hook

AWS_CONNECTION_ID = 'aws_localstack'
AWS_BUCKET_NAME = 'my-test-bucket'

def create_bucket(**context):
    s3_hook = S3Hook(AWS_CONNECTION_ID)
    s3_hook.create_bucket(bucket_name=AWS_BUCKET_NAME, region_name='eu-west-2')

    return s3_hook.check_for_bucket(bucket_name=AWS_BUCKET_NAME)

def upload_object(**context):
    s3_hook = S3Hook(AWS_CONNECTION_ID)
    s3_hook.load_string(
        string_data='JustSomeTestText',
        key='MyTestFile',
        bucket_name=AWS_BUCKET_NAME
    )

    return s3_hook.check_for_key(key='MyTestFile', bucket_name=AWS_BUCKET_NAME)

def download_object(**context):
    s3_hook = S3Hook(AWS_CONNECTION_ID)

    return s3_hook.read_key(key='MyTestFile', bucket_name=AWS_BUCKET_NAME)

default_args = {
    'owner': 'airflow',
    'depends_on_past': True,
    'start_date': days_ago(1)
}
dag = DAG('s3_local_stack', schedule_interval='00 * * * *', default_args=default_args)

create_bucket = PythonOperator(
    task_id='create_bucket',
    python_callable=create_bucket,
    provide_context=True,
    dag=dag
)

upload_object = PythonOperator(
    task_id='upload_object',
    python_callable=upload_object,
    provide_context=True,
    dag=dag
)

download_object = PythonOperator(
    task_id='download_object',
    python_callable=download_object,
    provide_context=True,
    dag=dag
)

finish = DummyOperator(
    task_id='finish',
    dag=dag
)

create_bucket >> upload_object >> download_object >> finish
