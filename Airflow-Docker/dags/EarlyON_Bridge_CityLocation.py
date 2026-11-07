from airflow import DAG
from airflow.providers.common.sql.operators.sql import SQLExecuteQueryOperator
from airflow.providers.microsoft.mssql.hooks.mssql import MsSqlHook
from airflow.decorators import task
from datetime import datetime, timedelta
import pandas as pd
import os
import time
import openpyxl 

default_args = {
    'owner': 'EarlyON',
    'retries': 1,
    'retry_delay': timedelta(minutes=2),
}

with DAG(
    dag_id='EarlyON_Bridge_CityLocation',
    default_args=default_args,
    description='Delete, Duplicates, Mapping, IDs',
    start_date=datetime(2024, 1, 1),
    schedule='@daily',
    catchup=False,
    tags=['EarlyON', 'City', 'Location'],
) as dag:


    truncate_source_table = SQLExecuteQueryOperator(
        task_id='truncate_source_table',
        conn_id='SQL_Server_EarlyON',
        sql="TRUNCATE TABLE dbo.Source_CityLocation;",
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
        df = df.iloc[:, [1, 5]].drop_duplicates()
        df = df.sort_values(by='MunicipalityCityTown', ascending=True)
        df = df.dropna()
        df = df[df['NameofLocation'] != 'Missing Value']
        df.rename(columns={'NameofLocation': 'Location'}, inplace=True)
        df.rename(columns={'MunicipalityCityTown': 'City'}, inplace=True)
        output_file = directory + chr(47) + 'CityManager.xlsx'
        df.to_excel(output_file, sheet_name="CityManager", index=False, engine='openpyxl')
                        
        hook = MsSqlHook(mssql_conn_id='SQL_Server_EarlyON')
        engine = hook.get_sqlalchemy_engine()

        # Fix: use engine.begin() to obtain a Connection object, not the Engine itself
        with engine.begin() as conn:
            df.to_sql(
                name='Source_CityLocation',
                schema='dbo',
                con=conn,
                if_exists='append',
                index=False,
            )

    delete_duplicates = SQLExecuteQueryOperator(
        task_id='delete_duplicates',
        conn_id='SQL_Server_EarlyON',
        sql="EXECUTE dbo.delete_duplicates_source_cityLocation_city",
        autocommit=True,
    )

    mapid1 = SQLExecuteQueryOperator(
        task_id='mapid1',
        conn_id='SQL_Server_EarlyON',
        sql="EXECUTE dbo.mapid_source_cityLocation_location",
        autocommit=True,
    )

    mapid2 = SQLExecuteQueryOperator(
        task_id='mapid2',
        conn_id='SQL_Server_EarlyON',
        sql="EXECUTE dbo.mapid_source_cityLocation_city",
        autocommit=True,
    )

    delete_nulls1 = SQLExecuteQueryOperator(
        task_id='delete_nulls1',
        conn_id='SQL_Server_EarlyON',
        sql="DELETE dbo.Source_CityLocation WHERE CityID IS NULL",
        autocommit=True,
    )

    delete_nulls2 = SQLExecuteQueryOperator(
        task_id='delete_nulls2',
        conn_id='SQL_Server_EarlyON',
        sql="DELETE dbo.Source_CityLocation WHERE LocationID IS NULL",
        autocommit=True,
    )

    load_target_table = SQLExecuteQueryOperator(
        task_id='load_target_table',
        conn_id='SQL_Server_EarlyON',
        sql="EXECUTE dbo.load_target_citylocation",
        autocommit=True,
    )


    # Task Sequence
    truncate_source_table >> load_source_table() >> delete_duplicates >> mapid1 >> mapid2 >> delete_nulls1 >> delete_nulls2 >> load_target_table