"""
##############################################
Load Dimensional table: dbo.Province
##############################################
"""
from airflow import DAG
from airflow.providers.common.sql.operators.sql import SQLExecuteQueryOperator
from airflow.providers.microsoft.mssql.hooks.mssql import MsSqlHook
from airflow.decorators import task
from datetime import datetime, timedelta
import pandas as pd

default_args = {
    'owner': 'EarlyON',
    'retries': 1,
    'execution_timeout': timedelta(seconds=300),
}

with DAG(
    dag_id='EarlyON_DimProvince',
    default_args=default_args,
    description='Load Province dimension',
    start_date=datetime(2026, 10, 21),
    schedule=None,              # triggered by master DAG
    catchup=False,
    max_active_runs=1,
    tags=['Province', 'EarlyON', 'csv', 'dimension'],
) as dag:

    truncate_source_table = SQLExecuteQueryOperator(
        task_id='truncate_source_table',
        conn_id='SQL_Server_EarlyON',
        sql="TRUNCATE TABLE dbo.Province;",
        autocommit=True,
    )

    @task
    def load_source_table():
        csv_path = '/opt/airflow/data/csv/Province.csv'
        df = pd.read_csv(csv_path)
        print(f"Read {len(df)} rows from {csv_path}")
        print(df.head().to_string(index=False))

        hook = MsSqlHook(mssql_conn_id='SQL_Server_EarlyON')
        engine = hook.get_sqlalchemy_engine()
        df.to_sql(
            name='Province',
            schema='dbo',
            con=engine,
            if_exists='append',
            index=False,
            method='multi',
            chunksize=1000,
        )
        print(f"Successfully inserted {len(df)} rows into dbo.Province")

    load_target_table = SQLExecuteQueryOperator(
        task_id='load_target',
        conn_id='SQL_Server_EarlyON',
        sql="EXECUTE dbo.LoadTarget_Province;",
        autocommit=True,
    )

    truncate_source_table >> load_source_table() >> load_target_table