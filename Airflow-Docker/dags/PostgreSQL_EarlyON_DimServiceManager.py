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
    dag_id='PostgreSQL_EarlyON_DimServiceManager',
    default_args=default_args,
    description='Truncate Source, Load Source, Load Target',
    start_date=datetime(2024, 1, 1),
    schedule='@daily',
    catchup=False,
    tags=['EarlyON', 'Service', 'Manager'],
) as dag:

    truncate_source_table = SQLExecuteQueryOperator(
        task_id='truncate_source_table',
        conn_id='PostgreSQL_EarlyON',
        sql="TRUNCATE TABLE public.source_servicemanager RESTART IDENTITY CASCADE;",
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
        df = df.iloc[:, 0].drop_duplicates().to_frame()
        df = df.sort_values(by='ServiceSystemManagers', ascending=True)
        df = df.dropna()
        df = df[df['ServiceSystemManagers'] != 'Missing Value']
        df['ServiceSystemManagers'] = (
            df['ServiceSystemManagers']
                .str.replace("Utd", "United", regex=False)
                .str.replace("Cty", "County", regex=False)
                .str.replace(".", " ", regex=False)
                .str.replace("DSAB", "District Services Administration Board", regex=False)
                .str.replace("SSAB", "Social Services Administration Board", regex=False)
                .str.replace("Distr", "District", regex=False)
                .str.replace("Dst Svs Bd", "District Services Board", regex=False)
                .str.replace("Dist Svs Bd", "District Services Board", regex=False)
                .str.replace("SAB", "Services Administration Board", regex=False)
                .str.replace("Dst  Svs Bd", "District Services Board", regex=False)
                .str.replace("Dst Svs Bd", "District Services Board", regex=False)
        )

        df.rename(columns={'ServiceSystemManagers': 'servicemanager'}, inplace=True)
        df['provinceid'] = 9
        #output_file = directory + chr(47) + 'ServiceManager_test.xlsx'
        #df.to_excel(output_file, sheet_name="ServiceManager", index=False, engine='openpyxl')
        
        hook = PostgresHook(postgres_conn_id='PostgreSQL_EarlyON')
        engine = hook.get_sqlalchemy_engine()

        # Fix: use engine.begin() to obtain a Connection object, not the Engine itself
        with engine.begin() as conn:
            df.to_sql(
                name='source_servicemanager',
                schema='public',
                con=conn,
                if_exists='append',
                index=False,
            )
    
    load_target_table = SQLExecuteQueryOperator(
        task_id='load_target_table',
        conn_id='PostgreSQL_EarlyON',
        sql="CALL public.load_target_table_servicemanager();",
        autocommit=True,
    )

    # Task Sequence
    truncate_source_table >> load_source_table() >> load_target_table