-- Run as the application schema.
-- USER_HOST_ACES view shows the network privileges visible to the current user


SELECT host,
       lower_port,
       upper_port,
       privilege,
       status
FROM user_host_aces
WHERE host = 'postman-echo.com';