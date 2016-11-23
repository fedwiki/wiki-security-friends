# Federated Wiki - Security Plug-in: Friends

This module creates its own secrets which it maintains in the `status/owner.json` file. No internet access is necessary to claim sites at will and ensure single owner access once claimed. We expect a farm operator is "friends" with each user and is available to help restore the long-lived session should it be lost.

Write access to a claimed site can be restored by clicking on the padlock and pasting in the site's
secret. This can be retrieved from the `status/owner.json` file by the site operator.

## Configuration

Launch the wiki server with three additional arguments, `security_type`, `cookieSecret` and `session_duration`.

```
--security_type friends
--cookieSecret 'REPLACE-THIS-SECRET'
--session_duration n
```

The security_type friends specifies to handle authentication with this module. Setting a `cookieSecret` makes sure that the session cookie encryption is consistent between server restarts. Otherwise each wiki owner would be logged out following a wiki server restart and would need to use the reclaim code to acquire a new session.
Setting a `session_duration` allows you to set a longer time for the sites sessions. `n` is the number of days that the session will last, the default is 7 days.
