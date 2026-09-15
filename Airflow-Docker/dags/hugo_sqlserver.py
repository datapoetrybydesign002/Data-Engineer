"""
hugo_province.py - Truncate and load dbo.Province table using modern operator
"""
from airflow import DAG
from airflow.providers.common.sql.operators.sql import SQLExecuteQueryOperator
from datetime import datetime

with DAG(
    dag_id="hugo_province",
    description="Truncate and load Province table in EarlyON_v2",
    start_date=datetime(2026, 9, 13),
    schedule="@daily",
    catchup=False,
    tags=["hugo", "sqlserver", "province"],
) as dag:

    # ---- STEP 1: Truncate the table ----
    truncate_table = SQLExecuteQueryOperator(
        task_id="truncate_province",
        conn_id="SQL_Server_EarlyON",  # Note: parameter is conn_id, not mssql_conn_id
        sql="TRUNCATE TABLE dbo.Province;",
        autocommit=True,
    )

    # ---- STEP 2: Insert one row ----
    insert_province = SQLExecuteQueryOperator(
        task_id="insert_province",
        conn_id="SQL_Server_EarlyON",
        sql="""
            INSERT INTO dbo.Province 
                (Province, ProvinceCode, CreatedDateTime, ModifiedDateTime)
            VALUES 
                ('Ontario', 'ON', GETDATE(), GETDATE());
        """,
        autocommit=True,
    )

    truncate_table >> insert_province