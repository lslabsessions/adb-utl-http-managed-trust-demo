-- Optional cleanup. Run as ADMIN or another ACL administrator
-- Replace APP_USER with the schema used for the demo.

SET SERVEROUTPUT ON

DEFINE TARGET_SCHEMA = 'APP_DEV'

DECLARE
    l_schema_name VARCHAR2(128) := UPPER('&TARGET_SCHEMA');
    BEGIN
        DBMS_NETWORK_ACL_ADMIN.REMOVE_HOST_ACE(
            host       => 'postman-echo.com',
            lower_port => 443,
            upper_port => 443,
            ace        => XS$ACE_TYPE(
                privilege_list => XS$NAME_LIST('http'),
                principal_name => l_schema_name,
                principal_type => XS_ACL.PTYPE_DB
            )
        );
        DBMS_OUTPUT.PUT_LINE('Removed CONNECT from ' || l_schema_name);
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('CONNECT cleanup note: ' || SQLERRM);
    END;
/

