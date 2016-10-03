# Federated Wiki - Security Plug-in: Friends

This module creates its own secrets which it maintains in the `status/owner.json` file. No internet access is necessary to claim sites at will and insure insure single owner access once claimed. We expect a farm operator is "friends" with each user and is available to help restore the long-lived session should it be lost.

Write access to a claimed site can be restored by following a reclaim link of the form:
```
http://site.example.com/auth/reclaim/73aa69f4a5f904272a56a09e31cb580e8d01dbd4b9c3f5d2867f2b25bbfb0114
```
where the hex code has been retrieved from the `status.owner.json` file by the friendly site operator.

## Configuration

Launch the wiki server with two additional arguments, security_type and cookieSecret.

- --security_type friends
- --cookieSecret 'CONSISTENT-SECRET'

The security_type friends specifies to handle authentication with this module. The CONSISTENT-SECRET makes sure that the session cookie encryption is consistent between server restarts. Otherwise each site owner would be logged out and would need to use the auth/reclaim to acquire a new session.
