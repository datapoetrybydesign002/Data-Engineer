"""
##############################################
Load Dimensional table: public.province
##############################################
"""
from airflow import DAG
from airflow.providers.common.sql.operators.sql import SQLExecuteQueryOperator
from airflow.providers.postgres.hooks.postgres import PostgresHook
from airflow.decorators import task
from datetime import datetime, timedelta
import pandas as pd

default_args = {
    'owner': 'EarlyON',
    'retries': 1,
    'execution_timeout': timedelta(seconds=300),
}

with DAG(
    dag_id='PostgreSQL_DimProvince', # Aligning with the DAG name in your logs
    default_args=default_args,
    description='Load Province dimension',
    start_date=datetime(2026, 10, 21),
    schedule=None,              
    catchup=False,
    max_active_runs=1,
    tags=['Province', 'EarlyON', 'csv', 'dimension'],
) as dag:

    # 1. Truncate the SOURCE table
    truncate_source_table = SQLExecuteQueryOperator(
        task_id='truncate_source_table',
        conn_id='PostgreSQL_EarlyON',
        sql="TRUNCATE TABLE public.source_province RESTART IDENTITY;",
        autocommit=True,
    )

    # 2. Load CSV into the SOURCE table using Pandas & SQLAlchemy Engine
    @task
    def load_source_table():
        csv_path = '/opt/airflow/data/csv/Province.csv'
        df = pd.read_csv(csv_path)
        #print(f"Read {len(df)} rows from {csv_path}")
        
        # 1. IMMEDIATELY lowercase all column names to prevent case-sensitivity issues
        df.columns = df.columns.str.lower()
        
        # 2. Drop ID and CreatedDate so Postgres generates them automatically
        if 'id' in df.columns:
            df = df.drop(columns=['id'])
        df = df.drop(columns=['createddate', 'created_by', 'createdby'], errors='ignore')

        #print(f"Dataframe columns to be inserted: {df.columns.tolist()}")

        # 3. Get the SQLAlchemy engine from the Airflow Hook
        hook = PostgresHook(postgres_conn_id='PostgreSQL_EarlyON')
        engine = hook.get_sqlalchemy_engine()

        try:
            #print(f"Executing bulk insert of {len(df)} rows...")
            
            # 4. Use Pandas to_sql with the SQLAlchemy engine
            df.to_sql(
                name='source_province',
                schema='public',
                con=engine,               # SQLAlchemy engine works perfectly
                if_exists='append',
                index=False,
                method='multi',           # True bulk insert
                chunksize=5000            # Batch size
            )
            #print(f"Successfully inserted {len(df)} rows into public.source_province")
            
        except Exception as e:
            #print(f"Error during insert: {e}")
            raise e

    # 3. Call the stored procedure using CALL
    load_target_table = SQLExecuteQueryOperator(
        task_id='load_target',
        conn_id='PostgreSQL_EarlyON',
        sql="CALL public.load_target_table_province();",
        autocommit=True,
    )

    # Define the DAG dependencies
    truncate_source_table >> load_source_table() >> load_target_table