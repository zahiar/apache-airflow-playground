from airflow.models.dag import DAG
from airflow.operators.dummy_operator import DummyOperator
from airflow.utils.dates import days_ago

default_args = {
    'owner': 'airflow',
    'depends_on_past': True,
    'start_date': days_ago(1)
}
dag = DAG('dummy_dag', schedule_interval='00 * * * *', default_args=default_args)

task_1 = DummyOperator(
    task_id='task_1',
    dag=dag
)
task_2 = DummyOperator(
    task_id='task_2',
    dag=dag
)
task_3 = DummyOperator(
    task_id='task_3',
    dag=dag
)

task_1 >> task_2 >> task_3