-- Run as ADMIN or another account allowed to manage network ACLs
-- Replace APP_USER with the schema that will execute UTL_HTTP.

SET SERVEROUTPUT ON

DEFINE TARGET_SCHEMA = APP_USER

DECLARE
    l_schema_name VARCHAR2(128) := UPPER('&TARGET_SCHEMA');

    BEGIN
        DBMS_NETWORK_ACL_ADMIN.APPEND_HOST_ACE(
            host => 'postman-echo.com',
            lower_port => 443,
            upper_port => 443,
            ace  => XS$ACE_TYPE(
                privilege_list => XS$NAME_LIST('http'),
                principal_name => l_schema_name,
                principal_type => XS_ACL.PTYPE_DB
            )
        );
        DBMS_OUTPUT.PUT_LINE('Granted http on postman-echo.com to ' || l_schema_name);
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE = -24243 THEN
                DBMS_OUTPUT.PUT_LINE('RESOLVE ACE already exists for ' || l_schema_name);
            ELSE
                RAISE;
            END IF;
    END;
/