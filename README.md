# UTL_HTTP from Oracle Autonomous Database without a user-managed wallet

This repository demonstrates outbound HTTPS GET and POST requests from Oracle Autonomous Database (ADB) with UTL_HTTP, without calling UTL_HTTP.SET_WALLET and without creating a request context for a custom wallet.

The example uses the public **Postman Echo** service. Its purpose is to return the details of the request as JSON, which makes it suitable for a reproducible integration test.

> **Important clarification**
>
> This project does **not** claim that TLS certificate validation or Oracle Wallet technology is unnecessary. It demonstrates that application code does not need to supply a **user-managed wallet** when the remote certificate chain is already trusted by the Autonomous Database managed environment. A custom wallet may still be needed for private certificate authorities, self-signed certificates, or mutual TLS.


## From on-premises Oracle Database to Autonomous Database

Developers coming from on-premises Oracle Database environments may be accustomed to creating and configuring an Oracle Wallet before making outbound HTTPS requests with UTL_HTTP.

In Oracle Autonomous Database, a user-managed wallet does not need to be explicitly configured when the remote endpoint presents a certificate chain that is already trusted by the Autonomous Database managed trust store.

In this scenario, the request can be made without calling UTL_HTTP.SET_WALLET or providing a custom wallet through a request context.

A network Access Control Entry is still required to allow the database user to access the destination host.

## What this repository demonstrates

- Network ACLs and TLS trust are separate concerns.
- An ACL is still required for the target host.
- HTTPS calls can be made without UTL_HTTP.SET_WALLET when the certificate is already trusted by ADB.
- HTTP status, response headers, response body, and detailed Oracle errors can be captured.

## Test service


The service is only for testing purposes. Availability and behavior can change. Do not send credentials, personal data, or confidential information to a public echo service. The JSON files under 'examples/' are representative response excerpts; the service may return additional or differently ordered fields.


## Prerequisites

- Oracle Autonomous Database with access to run PL/SQL.
- A schema in which the POSTMAN_HTTP_PKG package can be created.
- An administrator able to grant the schema network access to postman-echo.com on TCP port 443.

## Run the demo/test

### 1. Check the environment and acl grants

Run as the application schema:

- sql/001_environment.sql
- sql/010_check_network_access.sql

### 2. Grant network access

Edit sql/005_grant_network_access.sql and replace APP_USER with the target schema. Run the script as ADMIN or another account with permission to manage network ACLs.

The script grants:

- http to postman-echo.com on port 443;

### 3. Verify the ACL acess to the application schema after the grants

- sql/010_check_network_access.sql

### 4. Install the pl/sql package

Run as the application schema:

- sql/015_POSTMAN_HTTP_PKG.sql

### 5. Execute the GET example

- sql/020_run_get.sql

Expected result: HTTP status 200 and a JSON response containing the arg0=Hello & arg1=ADB query parameters.

### 6. Execute the POST example

- sql/025_run_post.sql

Expected result: HTTP status 200 and a JSON response containing the JSON body sent by the package.


## Why there is no wallet call in the code

The package intentionally does not call any of the following:


UTL_HTTP.SET_WALLET(...)
UTL_HTTP.CREATE_REQUEST_CONTEXT(...)


The successful HTTPS request is the evidence that the destination certificate chain is accepted by the trust configuration available to ADB. The ACL only authorizes the schema to contact the host; it does not replace TLS certificate validation.

## When a custom wallet can still be required

A user-managed wallet may still be necessary when the remote service uses:

- a private certificate authority;
- a self-signed certificate;
- an incomplete or untrusted certificate chain;
- mutual TLS with a client certificate;
- credentials stored in a wallet.

## Security notes

- Grant access to the exact host and port whenever possible.
- Avoid wildcard ACLs for demonstration and production environments.
- Never commit wallets, passwords, tokens, private keys, or internal endpoint names.
- Do not send sensitive data to the Postman Echo service.
- Remove the ACL after testing when it is no longer required.


## Documentation references

- [Oracle Database PL/SQL Packages and Types Reference: UTL_HTTP](https://docs.oracle.com/en/database/oracle/oracle-database/26/arpls/UTL_HTTP.html)
- [Oracle Database PL/SQL Packages and Types Reference: DBMS_NETWORK_ACL_ADMIN](https://docs.oracle.com/en/database/oracle/oracle-database/19/arpls/DBMS_NETWORK_ACL_ADMIN.html)
- [Oracle Database PL/SQL Packages and Types Reference: Make External Calls Using a Customer-Managed Wallet](https://docs.oracle.com/en-us/iaas/autonomous-database-serverless/doc/external-calls-with-customer-managed-wallet.html)
- [Postman documentation: Echo API](https://learning.postman.com/docs/reference/developer-resources/echo-api/)

## License

This project is licensed under the MIT License.
