"""
hugo.py - My personal Hello World DAG
Author: Hugo
Created: 2026-09-13
Description: A simple two-step DAG to learn Airflow 3.x
"""

from airflow import DAG
from airflow.operators.python import PythonOperator
from datetime import datetime, timedelta
import logging

# Setup logging so messages appear in Airflow logs
logger = logging.getLogger(__name__)

# ============================================================
# DEFAULT ARGUMENTS
# Applied to all tasks in this DAG unless overridden
# ============================================================
default_args = {
    'owner': 'hugo',
    'depends_on_past': False,
    'start_date': datetime(2026, 9, 13),
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}


# ============================================================
# TASK FUNCTIONS
# These are the Python functions that will run
# ============================================================

def step_one():
    """Step 1: Say hello"""
    logger.info("=" * 60)
    logger.info("🚀 STEP ONE: Hello from Hugo's first Airflow DAG!")
    logger.info(f"🕐 Current time: {datetime.now()}")
    logger.info("=" * 60)
    print("Step One completed successfully!")


def step_two():
    """Step 2: Say goodbye"""
    logger.info("=" * 60)
    logger.info("✅ STEP TWO: Hugo's DAG is working perfectly!")
    logger.info(f"🕐 Current time: {datetime.now()}")
    logger.info("=" * 60)
    print("Step Two completed successfully!")


# ============================================================
# DAG DEFINITION
# ============================================================

with DAG(
    dag_id='hugo',                          # Unique name shown in Airflow UI
    default_args=default_args,
    description="Hugo's first Airflow DAG",
    start_date=datetime(2026, 9, 13),
    schedule='@daily',                      # Airflow 3.x syntax!
    catchup=False,
    tags=['hugo', 'learning', 'hello'],
) as dag:

    # ---- TASK 1 ----
    task_step_one = PythonOperator(
        task_id='step_one',
        python_callable=step_one,
    )

    # ---- TASK 2 ----
    task_step_two = PythonOperator(
        task_id='step_two',
        python_callable=step_two,
    )

    # ---- DEPENDENCIES ----
    # step_one runs FIRST, then step_two
    task_step_one >> task_step_two