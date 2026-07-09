# Command Catalog

## SQL*Plus Session Commands

```sql
SHOW USER;
SHOW CON_NAME;
SHOW CON_ID;
SET LINESIZE 132;
SET PAGESIZE 100;
SET LONG 5000;
COLUMN username FORMAT A20;
COLUMN default_tablespace FORMAT A20;
SPOOL lab-output.txt;
SPOOL OFF;
```

## Dictionary And Metadata Queries

```sql
SELECT * FROM user_users;
SELECT systimestamp FROM dual;
SELECT * FROM v$version;
SELECT name, open_mode FROM v$pdbs;
SELECT con_id, name, open_mode, open_time FROM v$pdbs;
SELECT tablespace_name, con_id FROM cdb_tablespaces;
SELECT file_name, con_id FROM cdb_data_files;
SELECT file_name, con_id FROM cdb_temp_files;
SELECT name FROM v$controlfile;
SELECT group#, member FROM v$logfile;
SELECT log_mode FROM v$database;
SELECT text FROM dba_views WHERE view_name = 'DBA_VIEWS';
```

## DDL And DML Patterns

```sql
CREATE TABLE ...;
ALTER TABLE ... ADD CONSTRAINT ...;
INSERT INTO ... VALUES (...);
UPDATE ... SET ... WHERE ...;
DELETE FROM ... WHERE ...;
COMMIT;
ROLLBACK;
DROP TABLE ... PURGE;
```

## Object Support Commands

```sql
CREATE SEQUENCE app_seq START WITH 1000 INCREMENT BY 1;
CREATE INDEX emp_dept_ix ON emp(dept_id);
CREATE OR REPLACE VIEW emp_summary_v AS SELECT ...;
CREATE SYNONYM employee_summary FOR emp_summary_v;
DESC emp;
```

## PDB Administration Patterns

```sql
CONNECT / AS SYSDBA;
ALTER SESSION SET CONTAINER = <PDB_NAME>;
ALTER PLUGGABLE DATABASE OPEN;
SHOW PARAMETER control_files;
SHOW PARAMETER db_recovery;
ALTER SYSTEM SWITCH LOGFILE;
```

## Storage Administration Patterns

```sql
CREATE TABLESPACE app_data DATAFILE '<DATAFILE_PATH>/app_data01.dbf' SIZE 10M AUTOEXTEND ON;
ALTER TABLESPACE app_data RENAME TO test_data;
ALTER TABLESPACE test_data READ ONLY;
ALTER TABLESPACE test_data READ WRITE;
ALTER TABLESPACE test_data ADD DATAFILE '<DATAFILE_PATH>/app_data02.dbf' SIZE 10M;
DROP TABLESPACE test_data INCLUDING CONTENTS AND DATAFILES;
ALTER DATABASE ADD LOGFILE GROUP 4 ('<REDO_PATH>/redo04a.log') SIZE 50M;
ALTER DATABASE ADD LOGFILE MEMBER '<REDO_PATH>/redo04b.log' TO GROUP 4;
```

## Data Pump Patterns

```bash
expdp <USER>/<PASSWORD>@<PDB_NAME> schemas=<SCHEMA_NAME> directory=<DIRECTORY_NAME> dumpfile=schema_export.dmp logfile=schema_export.log
impdp <USER>/<PASSWORD>@<PDB_NAME> schemas=<SCHEMA_NAME> directory=<DIRECTORY_NAME> dumpfile=schema_export.dmp logfile=schema_import.log
```
