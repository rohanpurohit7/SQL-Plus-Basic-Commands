-- Oracle SQL*Plus and PDB consolidated command lab
-- Replace placeholders such as <PDB_NAME>, <DATAFILE_PATH>, and <SCHEMA_NAME> before running.

SHOW USER;
SHOW CON_NAME;
SHOW CON_ID;
SET LINESIZE 132;
SET PAGESIZE 100;
COLUMN username FORMAT A20;
COLUMN default_tablespace FORMAT A20;
SELECT * FROM user_users;

DROP TABLE emp PURGE;
DROP TABLE dept PURGE;
DROP SEQUENCE app_seq;

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

UPDATE emp SET salary = salary * 1.05 WHERE dept_id = 10;
SELECT dept_id, COUNT(*) AS employee_count FROM emp GROUP BY dept_id;
ROLLBACK;

CREATE SEQUENCE app_seq START WITH 1000 INCREMENT BY 1;
CREATE INDEX emp_dept_ix ON emp(dept_id);
CREATE OR REPLACE VIEW emp_summary_v AS
SELECT d.dept_name, COUNT(e.emp_id) AS employee_count, AVG(e.salary) AS average_salary
FROM dept d
LEFT JOIN emp e ON e.dept_id = d.dept_id
GROUP BY d.dept_name;
CREATE SYNONYM employee_summary FOR emp_summary_v;
SELECT * FROM employee_summary;

-- Privileged CDB/PDB inspection commands:
-- CONNECT / AS SYSDBA;
-- SHOW CON_NAME;
-- SHOW CON_ID;
-- SELECT name, open_mode FROM v$pdbs;
-- ALTER SESSION SET CONTAINER = <PDB_NAME>;
-- ALTER PLUGGABLE DATABASE OPEN;
-- SELECT con_id, name, open_mode, open_time FROM v$pdbs;
-- SELECT tablespace_name, con_id FROM cdb_tablespaces;
-- SELECT file_name, con_id FROM cdb_data_files;
-- SELECT group#, member FROM v$logfile;
-- ARCHIVE LOG LIST;
