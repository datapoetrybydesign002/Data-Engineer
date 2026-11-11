from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.trigger_dagrun import TriggerDagRunOperator
from airflow.operators.empty import EmptyOperator

# Default arguments for the DAG
default_args = {
    'owner': 'EarlyON',
    'depends_on_past': False,
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=1),
}

with DAG(
    dag_id='EarlyON_Master_Waterfall',
    default_args=default_args,
    description='Master DAG to orchestrate a Waterfall execution of Dimensional then Bridge tables',
    # Airflow 3.x: use `schedule` (not `schedule_interval`)
    schedule='*/10 * * * *',   # every 10 minutes, 24/7
    start_date=datetime(2026, 11, 7),
    catchup=False,
    tags=['Master', 'EarlyON', 'Orchestration'],
) as dag:

    # ---------------------------------------------------------
    # Start / End markers
    # ---------------------------------------------------------
    start_task = EmptyOperator(task_id='start_pipeline')
    end_task   = EmptyOperator(task_id='end_pipeline')

    # ---------------------------------------------------------
    # WATERFALL SEQUENCE
    # ---------------------------------------------------------
    # This single list dictates the exact order of execution.
    # Dimensions first, followed by Bridges.
    ordered_dags = [
        # Dimensions
        'EarlyON_DimProvince',
        'EarlyON_DimServiceManager',
        'EarlyON_DimCity',
        'EarlyON_DimLocation',
        'EarlyON_DimAddress',
        'EarlyON_DimPostalCode',
        
        # Bridges
        'EarlyON_Bridge_CityManager',
        'EarlyON_Bridge_CityLocation',
        'EarlyON_Bridge_LocationAddress',
        'EarlyON_Bridge_AddressPostalCode'
    ]

    # We will store the tasks in a list so we can chain them together
    pipeline_tasks = []

    # Generate a trigger task for each DAG in the ordered list
    for dag_id in ordered_dags:
        trigger_task = TriggerDagRunOperator(
            task_id=f'trigger_{dag_id}',
            trigger_dag_id=dag_id,
            wait_for_completion=True, # MUST be True for a waterfall flow
            poke_interval=30,
            reset_dag_run=True,
            allowed_states=['success'],
            failed_states=['failed'],
        )
        pipeline_tasks.append(trigger_task)

    # ---------------------------------------------------------
    # DEPENDENCIES (The Waterfall)
    # ---------------------------------------------------------
    # Step 1: Start -> First Task
    start_task >> pipeline_tasks[0]

    # Step 2: Chain the rest of the tasks sequentially
    # This creates: Task1 >> Task2 >> Task3 >> ... >> Task10
    for i in range(len(pipeline_tasks) - 1):
        pipeline_tasks[i] >> pipeline_tasks[i + 1]

    # Step 3: Last Task -> End
    pipeline_tasks[-1] >> end_task