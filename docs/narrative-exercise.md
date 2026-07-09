# Narrative Exercise: SQL*Plus To Oracle PDB Administration

This exercise walks through a single database learning path. It starts with basic SQL*Plus setup, moves into schema and table manipulation, expands into advanced SQL objects, and finishes with Oracle container/pluggable database administration concepts.

## Scenario

You are onboarding to a development Oracle environment. Your tasks are to verify your session, create a small application schema, manipulate sample relational data, add database objects that support application use, and inspect the Oracle CDB/PDB environment that hosts the schema.

No personal, academic, institutional, or source-document identifiers are retained in this exercise.

## Phase 1: SQL*Plus Session Orientation

1. Connect to SQL*Plus.
2. Display the connected user and container context.
3. Format output for readable data dictionary queries.
4. Spool output when a command transcript is required.

```sql
SHOW USER;
SHOW CON_NAME;
SHOW CON_ID;
SET LINESIZE 132;
SET PAGESIZE 100;
COLUMN username FORMAT A20;
COLUMN default_tablespace FORMAT A20;
SELECT * FROM user_users;
SPOOL lab-output.txt;
SPOOL OFF;
```

## Phase 2: Build A Department And Employee Model

The base model uses departments and employees. The exercise demonstrates table creation, primary keys, foreign keys, inserts, and verification queries.

```sql
DROP TABLE emp PURGE;
DROP TABLE dept PURGE;

CREATE TABLE dept (
    dept_id NUMBER PRIMARY KEY,
    dept_name VARCHAR2(40) NOT NULL,
    location_name VARCHAR2(40)
);

CREATE TABLE emp (
    emp_id NUMBER PRIMARY KEY,
    dept_id NUMBER NOT NULL,
    emp_name VARCHAR2(60) NOT NULL,
    job_title VARCHAR2(40),
    salary NUMBER(10,2),
    CONSTRAINT emp_dept_fk FOREIGN KEY (dept_id) REFERENCES dept(dept_id)
);

INSERT INTO dept VALUES (10, 'OPERATIONS', 'REGION_A');
INSERT INTO dept VALUES (20, 'ANALYTICS', 'REGION_B');
INSERT INTO emp VALUES (100, 10, 'EMPLOYEE_100', 'ANALYST', 65000);
INSERT INTO emp VALUES (101, 20, 'EMPLOYEE_101', 'ENGINEER', 72000);
COMMIT;

SELECT * FROM dept;
SELECT * FROM emp;
```

## Phase 3: Manipulate And Query Tables

Use DML to update rows, remove rows, and verify changes. Keep transactions explicit.

```sql
UPDATE emp SET salary = salary * 1.05 WHERE dept_id = 10;
SELECT emp_id, emp_name, salary FROM emp ORDER BY emp_id;
DELETE FROM emp WHERE emp_id = 101;
ROLLBACK;
SELECT dept_id, COUNT(*) AS employee_count FROM emp GROUP BY dept_id;
```

## Phase 4: Add Application Objects

Sequences, indexes, views, and synonyms are common support objects around application tables.

```sql
CREATE SEQUENCE app_seq START WITH 1000 INCREMENT BY 1;
CREATE INDEX emp_dept_ix ON emp(dept_id);
CREATE OR REPLACE VIEW emp_summary_v AS
SELECT d.dept_name, COUNT(e.emp_id) AS employee_count, AVG(e.salary) AS average_salary
FROM dept d
LEFT JOIN emp e ON e.dept_id = d.dept_id
GROUP BY d.dept_name;

CREATE SYNONYM employee_summary FOR emp_summary_v;
SELECT * FROM employee_summary;
```

## Phase 5: Inspect CDB And PDB State

These commands are run by an appropriately privileged account in an Oracle multitenant environment.

```sql
CONNECT / AS SYSDBA;
SHOW CON_NAME;
SHOW CON_ID;
SELECT name, open_mode FROM v$pdbs;
ALTER SESSION SET CONTAINER = <PDB_NAME>;
SHOW CON_NAME;
ALTER PLUGGABLE DATABASE OPEN;
SELECT con_id, name, open_mode, open_time FROM v$pdbs;
```

## Phase 6: Inspect Storage And Recovery Metadata

These commands inspect tablespaces, datafiles, control files, redo logs, archive mode, and recovery settings.

```sql
SELECT tablespace_name, con_id FROM cdb_tablespaces;
SELECT file_name, con_id FROM cdb_data_files;
SELECT file_name, con_id FROM cdb_temp_files;
SELECT name FROM v$controlfile;
SHOW PARAMETER control_files;
SELECT group#, member FROM v$logfile;
SELECT log_mode FROM v$database;
ARCHIVE LOG LIST;
SHOW PARAMETER db_recovery;
```

## Phase 7: Manage Tablespaces And Redo Logs

Use these patterns carefully in non-production lab environments.

```sql
CREATE TABLESPACE app_data DATAFILE '<DATAFILE_PATH>/app_data01.dbf' SIZE 10M AUTOEXTEND ON NEXT 5M MAXSIZE 100M;
ALTER TABLESPACE app_data RENAME TO test_data;
ALTER TABLESPACE test_data READ ONLY;
ALTER TABLESPACE test_data READ WRITE;
ALTER TABLESPACE test_data ADD DATAFILE '<DATAFILE_PATH>/app_data02.dbf' SIZE 10M;
DROP TABLESPACE test_data INCLUDING CONTENTS AND DATAFILES;

ALTER DATABASE ADD LOGFILE GROUP 4 ('<REDO_PATH>/redo04a.log') SIZE 50M;
ALTER DATABASE ADD LOGFILE MEMBER '<REDO_PATH>/redo04b.log' TO GROUP 4;
ALTER SYSTEM SWITCH LOGFILE;
```

## Phase 8: Advanced Objects

Advanced labs introduced partitioning, external tables, materialized views, and Data Pump patterns.

```sql
CREATE TABLE sales_partitioned (
    sale_id NUMBER,
    sale_date DATE,
    amount NUMBER(10,2)
)
PARTITION BY RANGE (sale_date) (
    PARTITION sales_2025 VALUES LESS THAN (DATE '2026-01-01'),
    PARTITION sales_2026 VALUES LESS THAN (DATE '2027-01-01')
);

CREATE MATERIALIZED VIEW emp_dept_mv
BUILD IMMEDIATE
REFRESH COMPLETE ON DEMAND
AS
SELECT d.dept_name, COUNT(e.emp_id) AS employee_count
FROM dept d LEFT JOIN emp e ON e.dept_id = d.dept_id
GROUP BY d.dept_name;

EXEC DBMS_MVIEW.REFRESH('EMP_DEPT_MV');

-- Shell examples, run outside SQL*Plus:
-- expdp <USER>/<PASSWORD>@<PDB_NAME> schemas=<SCHEMA_NAME> directory=<DIRECTORY_NAME> dumpfile=schema_export.dmp logfile=schema_export.log
-- impdp <USER>/<PASSWORD>@<PDB_NAME> schemas=<SCHEMA_NAME> directory=<DIRECTORY_NAME> dumpfile=schema_export.dmp logfile=schema_import.log
```

