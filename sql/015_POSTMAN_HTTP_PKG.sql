-- Run as the application schema.
-- This package does not call UTL_HTTP.SET_WALLET and does not create a request context for a custom wallet.

SET DEFINE OFF

create or replace PACKAGE POSTMAN_HTTP_PKG AUTHID CURRENT_USER AS
    PROCEDURE get_request;

    PROCEDURE post_request(
        p_message IN VARCHAR2 DEFAULT 'Hello from Oracle Autonomous Database'
    );
END POSTMAN_HTTP_PKG;
/


create or replace PACKAGE BODY POSTMAN_HTTP_PKG AS
    v_get_url  CONSTANT VARCHAR2(4000) := 'https://postman-echo.com/get?arg0=Hello&arg1=ADB';
    v_post_url CONSTANT VARCHAR2(4000) :='https://postman-echo.com/post';

    PROCEDURE print_response(
        p_response IN OUT NOCOPY UTL_HTTP.RESP
    ) IS
        v_name   VARCHAR2(256);
        v_value  VARCHAR2(32767);
        v_buffer VARCHAR2(32767);
    BEGIN
        DBMS_OUTPUT.PUT_LINE('HTTP status : ' || p_response.status_code ||
                             ' ' || p_response.reason_phrase);
        DBMS_OUTPUT.PUT_LINE('--- Response headers ---');

        FOR i IN 1 .. UTL_HTTP.GET_HEADER_COUNT(p_response) LOOP
            UTL_HTTP.GET_HEADER(p_response, i, V_name, V_value);
            DBMS_OUTPUT.PUT_LINE(v_name || ': ' || v_value);
        END LOOP;

        DBMS_OUTPUT.PUT_LINE('--- Response body ---');
        BEGIN
            LOOP
                UTL_HTTP.READ_TEXT(p_response, v_buffer, 32767);
                DBMS_OUTPUT.PUT_LINE(v_buffer);
            END LOOP;
        EXCEPTION
            WHEN UTL_HTTP.END_OF_BODY THEN
                NULL;
        END;
    END print_response;

    PROCEDURE print_error IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('SQLCODE  : ' || SQLCODE);
        DBMS_OUTPUT.PUT_LINE('SQLERRM  : ' || SQLERRM);
        DBMS_OUTPUT.PUT_LINE('UTL_HTTP : ' || UTL_HTTP.GET_DETAILED_SQLERRM);
    EXCEPTION
        WHEN OTHERS THEN
            NULL;
    END print_error;

    PROCEDURE get_request IS
        v_request       UTL_HTTP.REQ;
        v_response      UTL_HTTP.RESP;
        v_response_open BOOLEAN := FALSE;
    BEGIN
        UTL_HTTP.SET_DETAILED_EXCP_SUPPORT(TRUE);
        UTL_HTTP.SET_TRANSFER_TIMEOUT(30);

        v_request := UTL_HTTP.BEGIN_REQUEST(
            url          => v_get_url,
            method       => 'GET',
            http_version => UTL_HTTP.HTTP_VERSION_1_1
        );

        UTL_HTTP.SET_HEADER(v_request, 'Accept', 'application/json');
        UTL_HTTP.SET_HEADER(v_request, 'User-Agent', 'oracle-adb-utl-http-demo/1.0');

        v_response := UTL_HTTP.GET_RESPONSE(v_request);
        v_response_open := TRUE;

        print_response(v_response);

        UTL_HTTP.END_RESPONSE(v_response);
        v_response_open := FALSE;
    EXCEPTION
        WHEN OTHERS THEN
            IF v_response_open THEN
                BEGIN
                    UTL_HTTP.END_RESPONSE(v_response);
                EXCEPTION
                    WHEN OTHERS THEN NULL;
                END;
            END IF;
            print_error;
            RAISE;
    END get_request;

    PROCEDURE post_request(
        p_message IN VARCHAR2 DEFAULT 'Hello from Oracle Autonomous Database'
    ) IS
        v_request       UTL_HTTP.REQ;
        v_response      UTL_HTTP.RESP;
        v_response_open BOOLEAN := FALSE;
        v_json          JSON_OBJECT_T := JSON_OBJECT_T();
        v_payload       VARCHAR2(32767);
        v_payload_raw   RAW(32767);
    BEGIN
        UTL_HTTP.SET_DETAILED_EXCP_SUPPORT(TRUE);
        UTL_HTTP.SET_TRANSFER_TIMEOUT(30);

        v_json.PUT('source', 'oracle-adb');
        v_json.PUT('message', p_message);
        v_payload := v_json.TO_STRING;

        v_payload_raw := UTL_I18N.STRING_TO_RAW(v_payload, 'AL32UTF8');

        v_request := UTL_HTTP.BEGIN_REQUEST(
            url          => v_post_url,
            method       => 'POST',
            http_version => UTL_HTTP.HTTP_VERSION_1_1
        );

        UTL_HTTP.SET_HEADER(v_request, 'Accept', 'application/json');
        UTL_HTTP.SET_HEADER(v_request, 'Content-Type', 'application/json; charset=UTF-8');
        UTL_HTTP.SET_HEADER(v_request, 'Content-Length', TO_CHAR(UTL_RAW.LENGTH(v_payload_raw)));
        UTL_HTTP.SET_HEADER(v_request, 'User-Agent', 'oracle-adb-utl-http-demo/1.0');
        UTL_HTTP.SET_HEADER(v_request, 'X-Demo-Source', 'Oracle Autonomous Database');
        UTL_HTTP.WRITE_RAW(v_request, v_payload_raw);

        v_response := UTL_HTTP.GET_RESPONSE(v_request);
        v_response_open := TRUE;

        print_response(v_response);

        UTL_HTTP.END_RESPONSE(v_response);
        v_response_open := FALSE;
    EXCEPTION
        WHEN OTHERS THEN
            IF v_response_open THEN
                BEGIN
                    UTL_HTTP.END_RESPONSE(v_response);
                EXCEPTION
                    WHEN OTHERS THEN NULL;
                END;
            END IF;
            print_error;
            RAISE;
    END post_request;
END POSTMAN_HTTP_PKG;
/