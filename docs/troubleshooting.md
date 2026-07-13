# Troubleshooting

## ORA-24247: network access denied by access control list (ACL)

Probable cause: the executing schema does not have the required network privilege for postman-echo.com.

Actions:

1. Confirm the package is executed by the application schema.
2. Run 010_check_network_access.sql as that schema.
3. Ask an ACL administrator to run 005_grant_network_access.sql with the correct target schema.

## ORA-29024: Certificate validation failure

Likely cause: the destination certificate chain is not accepted by the trust configuration currently available to the database, or the service is presenting an incomplete/changed chain.

Actions:

1. Confirm the exact hostname in the URL.
2. Test again later in case the public service is having a certificate issue.
3. Review whether the endpoint uses a private CA, self-signed certificate, or mutual TLS.
4. Use a user-managed wallet only when required and supported for the target scenario.

Do not disable certificate verification.

## ORA-29273: HTTP request failed

Use UTL_HTTP.GET_DETAILED_SQLERRM to get more detail and identify the underlying cause.


