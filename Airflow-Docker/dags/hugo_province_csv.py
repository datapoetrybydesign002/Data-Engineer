"""
hugo_province_csv.py
Truncate dbo.Province, then load 13 provinces from CSV using pandas.
"""
from airflow import DAG
from airflow.providers.common.sql.operators.sql import SQLExecuteQueryOperator
from airflow.providers.microsoft.mssql.hooks.mssql import MsSqlHook
from airflow.decorators import task
from datetime import datetime
import pandas as pd

default_args = {
    'owner': 'hugo',
    'retries': 1,
}

with DAG(
    dag_id='hugo_province_csv',
    default_args=default_args,
    description='Truncate and load Province from CSV using Pandas',
    start_date=datetime(2026, 9, 13),
    schedule='@daily',
    catchup=False,
    tags=['hugo', 'pandas', 'csv'],
) as dag:

    # STEP 1: Truncate the Province table
    truncate_table = SQLExecuteQueryOperator(
        task_id='truncate_province',
        conn_id='SQL_Server_EarlyON',
        sql="TRUNCATE TABLE dbo.Province;",
        autocommit=True,
    )

    # STEP 2: Read CSV → DataFrame → SQL Server
    @task
    def load_province_csv():
        csv_path = '/opt/airflow/data/csv/Province.csv'
        df = pd.read_csv(csv_path)
        print(f"Read {len(df)} rows from {csv_path}")
        print(df.to_string(index=False))

        hook = MsSqlHook(mssql_conn_id='SQL_Server_EarlyON')
        engine = hook.get_sqlalchemy_engine()

        df.to_sql(
            name='Province',
            schema='dbo',
            con=engine,
            if_exists='append',
            index=False,
        )
        print(f"Successfully inserted {len(df)} rows into dbo.Province")

    # Dependencies
    truncate_table >> load_province_csv()