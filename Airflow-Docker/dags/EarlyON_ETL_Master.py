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
    dag_id='EarlyON_Master_MM',
    default_args=default_args,
    description='Master DAG to orchestrate Dimension then Bridge tables',
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
    # PHASE 1: DIMENSION TABLES
    # ---------------------------------------------------------
    dim_dags = [
        'EarlyON_DimProvince',
        'EarlyON_DimServiceManager',
        'EarlyON_DimCity',
        'EarlyON_DimLocation',
        'EarlyON_DimAddress',
        'EarlyON_DimPostalCode',
    ]

    dim_tasks = []
    for dag_id in dim_dags:
        dim_tasks.append(
            TriggerDagRunOperator(
                task_id=f'trigger_{dag_id}',
                trigger_dag_id=dag_id,
                wait_for_completion=True,
                poke_interval=30,
                reset_dag_run=True,
                allowed_states=['success'],
                failed_states=['failed'],   # 'skipped' is not a valid DagRunState
            )
        )

    # ---------------------------------------------------------
    # PHASE 2: BRIDGE TABLES
    # ---------------------------------------------------------
    bridge_dags = [
        'EarlyON_Bridge_CityManager',
        'EarlyON_Bridge_CityLocation',
        'EarlyON_Bridge_LocationAddress',
        'EarlyON_Bridge_AddressPostalCode',
    ]

    bridge_tasks = []
    for dag_id in bridge_dags:
        bridge_tasks.append(
            TriggerDagRunOperator(
                task_id=f'trigger_{dag_id}',
                trigger_dag_id=dag_id,
                wait_for_completion=True,
                poke_interval=30,
                reset_dag_run=True,
                allowed_states=['success'],
                failed_states=['failed'],
            )
        )

    # ---------------------------------------------------------
    # DEPENDENCIES
    # ---------------------------------------------------------
    # Step 1: start -> all Dimension DAGs (fan-out)
    start_task >> dim_tasks

    # Step 2: every Dimension DAG -> every Bridge DAG
    # (Airflow 3.x: `chain(list, list)` requires equal lengths,
    #  and `list >> list` is not supported. Use nested loops.)
    for dim_task in dim_tasks:
        for bridge_task in bridge_tasks:
            dim_task >> bridge_task

    # Step 3: all Bridge DAGs -> end
    bridge_tasks >> end_task