-- Run as the application schema after the ACL access is granted and the package is deployed

SET SERVEROUTPUT ON

BEGIN
    POSTMAN_HTTP_PKG.get_request;
END;
/
