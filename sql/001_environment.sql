-- Run as the application schema.


SET SERVEROUTPUT ON

SELECT banner_full as "database_version"
FROM v$version;


SELECT SYSTIMESTAMP AS database_timestamp,
       CURRENT_TIMESTAMP AS session_timestamp,
       SESSIONTIMEZONE AS session_timezone
FROM dual;

