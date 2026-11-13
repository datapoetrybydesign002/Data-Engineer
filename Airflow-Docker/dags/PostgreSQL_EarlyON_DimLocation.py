from airflow import DAG
from airflow.providers.common.sql.operators.sql import SQLExecuteQueryOperator
from airflow.providers.postgres.hooks.postgres import PostgresHook
from airflow.decorators import task
from datetime import datetime, timedelta
import pandas as pd

default_args = {
    'owner': 'EarlyON',
    'retries': 1,
    'retry_delay': timedelta(minutes=2),
}

with DAG(
    dag_id='PostgreSQL_EarlyON_DimLocation',
    default_args=default_args,
    description='Truncate Source, Load Source, Load Target',
    start_date=datetime(2024, 1, 1),
    schedule='@daily',
    catchup=False,
    tags=['EarlyON', 'Location'],
) as dag:

    truncate_source_table = SQLExecuteQueryOperator(
        task_id='truncate_source_table',
        conn_id='PostgreSQL_EarlyON',
        sql="TRUNCATE TABLE public.source_location RESTART IDENTITY CASCADE;",
        autocommit=True,
    )


    @task
    def load_source_table():
        directory = '/opt/airflow/data/excel'
        directory = directory.replace(chr(92), chr(47))
        file_name = "earlyon_locationlist_english_production_2025-12-15"
        file_extension = ".xlsx"
        file_path = directory + chr(47) + file_name + file_extension
        df = pd.read_excel(file_path, sheet_name=0, dtype=str)
        df.columns = df.columns.str.replace(chr(32),"").str.replace(chr(47),"")
        df = df.fillna("Missing Value")
        df = df.iloc[:, 1].drop_duplicates().to_frame()
        df = df.sort_values(by='NameofLocation', ascending=True)
        df = df.dropna()
        df = df[df['NameofLocation'] != 'Missing Value']
        df.rename(columns={'NameofLocation': 'location'}, inplace=True)
        df['location'] = df['location'].str.replace(chr(42), "")
        df['location'] = df['location'].str.replace(chr(58), chr(32))
        df['location'] = df['location'].astype(str).str.strip()
        df = df.sort_values(by='location', ascending=True)
        #output_file = directory + chr(47) + 'Location.xlsx'
        #df.to_excel(output_file, sheet_name="Location", index=False, engine='openpyxl')
                
        hook = PostgresHook(postgres_conn_id='PostgreSQL_EarlyON')
        engine = hook.get_sqlalchemy_engine()

        # Fix: use engine.begin() to obtain a Connection object, not the Engine itself
        with engine.begin() as conn:
            df.to_sql(
                name='Source_Location',
                schema='public',
                con=conn,
                if_exists='append',
                index=False,
            )
    
    load_target_table = SQLExecuteQueryOperator(
        task_id='load_target_table',
        conn_id='PostgreSQL_EarlyON',
        sql="CALL public.load_target_table_location();",
        autocommit=True,
    )

    # Task Sequence
    truncate_source_table >> load_source_table() >> load_target_table