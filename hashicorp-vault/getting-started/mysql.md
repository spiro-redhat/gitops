MySQL 


*Enable the Database Secrets Engine*
The Database secrets engine generates credentials dynamically for various databases. In this track, we are using an instance of MySQL that is running on the same VM as the Vault server itself.


The Database credentials are time-bound and are automatically revoked when the Vault lease expires. The credentials can also be revoked at any time.

All secrets engines must be enabled before they can be used. Check which secrets engines are currently enabled.

```vault secrets list```
Note that the Database secrets engine is not enabled. Please enable it at the path "lob_a/workshop/database".

```vault secrets enable -path=lob_a/workshop/database database```

If you like, you can login to the Vault UI with the Vault token root and see that the database secrets engine has been enabled.


*Configure the Database Secrets Engine*
All secrets engines must be configured before they can be used.

We first need to configure the database secrets engine to use the MySQL database plugin and valid connection information. We are configuring a database connection called "wsmysqldatabase" that is allowed to use two roles that we will create below.

```
vault write lob_a/workshop/database/config/wsmysqldatabase \
  plugin_name=mysql-database-plugin \
  connection_url="{{username}}:{{password}}@tcp(localhost:3306)/" \
  allowed_roles="workshop-app","workshop-app-long" \
  username="hashicorp" \
  password="Password123"
```

This will not return anything if successful.

Note that the username and password are templated in the "connection_url" string, getting their values from the "username" and "password" fields. We do this so that reading the path "lob_a/workshop/database/config/wsmysqldatabase" will not show them.

To test this, try running this command:

```
vault read lob_a/workshop/database/config/wsmysqldatabase
```

You will not see the password.

We used the initial MySQL username "hashicorp" and password "Password123" above. Validate that you can login to the MySQL server with this command:
```
mysql -u hashicorp -pPassword123
```


You should be given a `mysql>` prompt.

Logout of the MySQL server by typing `\q` at the `mysql>` prompt. This should return you to the `root@vault-mysql-server:~#` prompt.

We can make the configuration of the database secrets engine even more secure by rotating the root credentials (actually just the password) that we passed into the configuration. We do this by running this command:

```
vault write -force lob_a/workshop/database/rotate-root/wsmysqldatabase
```

This should return "Success! Data written to: lob_a/workshop/database/rotate-root/wsmysqldatabase".

Now, if you try to login to the MySQL server with the same command given above, it should fail and give you the message "ERROR 1045 (28000): Access denied for user 'hashicorp'@'localhost' (using password: YES)". Please verify that:
```
mysql -u hashicorp -pPassword123

```

Note: You should not use the actual `root` user of the MySQL database (despite the reference to "root credentials"); instead, create a separate user with sufficient privileges to create users and to change its own password.

Now, you should create the first of the two roles we will be using, "workshop-app-long", which generates credentials with an initial lease of 1 hour that can be renewed for up to 24 hours.


```
vault write lob_a/workshop/database/roles/workshop-app-long \
  db_name=wsmysqldatabase \
  creation_statements="CREATE USER '{{name}}'@'%' IDENTIFIED BY '{{password}}';GRANT ALL ON my_app.* TO '{{name}}'@'%';" \
  default_ttl="1h" \
  max_ttl="24h"
```

This should return "Success! Data written to: lob_a/workshop/database/roles/workshop-app-long".

And then create the second role, "workshop-app" which has shorter default and max leases of 3 minutes and 6 minutes. (These are intentionally set long enough so that you can use the credentials generated for the role to connect to the database but also see them expire in the next challenge.)

```
vault write lob_a/workshop/database/roles/workshop-app \
  db_name=wsmysqldatabase \
  creation_statements="CREATE USER '{{name}}'@'%' IDENTIFIED BY '{{password}}';GRANT ALL ON my_app.* TO '{{name}}'@'%';" \
  default_ttl="3m" \
  max_ttl="6m"
```

This should return "Success! Data written to: lob_a/workshop/database/roles/workshop-app".

The database secrets engine is now configured to talk to the MySQL server and is allowed to create users with two different roles. In the next challenge, you'll generate credentials (username and password) for these roles.

*Generate and Use Dynamic Database Credentials*

https://www.vaultproject.io/docs/secrets/databases/mysql-maria/ 
https://www.vaultproject.io/docs/secrets/databases/#usage 
https://www.vaultproject.io/api/secret/databases/#generate-credentials


Now that you have configured the database secrets engine with a connection and two roles for the MySQL database, you can dynamically generate short-lived credentials against the roles and use them to connect to the database.

First, generate credentials for the role, "workshop-app-long", using a curl call against the Vault HTTP API and pipe the results to jq to make the JSON returned by the API easier to read:
```
curl --header "X-Vault-Token: root" "http://localhost:8200/v1/lob_a/workshop/database/creds/workshop-app-long" | jq
```
You should get something like this:

```
{
  "request_id": "7e4480d3-b8c5-8e21-d45c-29d3440cf01d",
  "lease_id": "lob_a/workshop/database/creds/workshop-app-long/QOsXNeNDruux0QeMVWAF34J3",
  "renewable": true,
  "lease_duration": 3600,
  "data": {
    "password": "A1a-yK2qJ18gRHqUbwJo",
    "username": "v-token-workshop-a-5SEQ8ZLwULeLJ"
  },
  "wrap_info": null,
  "warnings": null,
  "auth": null
}
```
In these results, you see a several things, including `lease_id`, `username`, and `password`. The first is used if you want to renew or revoke the credentials (as you will do in the next challenge). The username and password are used to connect to the database. Note that `renewable` has the value `true`, indicating that the lifetime of the credentials can be extended using Vault's sys/leases/renew API endpoint.

You can also generate credentials against the same role with the Vault CLI:
```
vault read lob_a/workshop/database/creds/workshop-app-long
```
This should return something like:
```
Key                Value
---                -----
lease_id           lob_a/workshop/database/creds/workshop-app-long/JeUGIL2xD6BzXSneqity8UmF
lease_duration     1h
lease_renewable    true
password           A1a-zy4ENaf2kwpzGk9t
username           v-token-workshop-a-DM0BJ3eMlMhbf
```

Next, generate credentials against the shorter role, "workshop-app", using the Vault CLI:
```
Key                Value
---                -----
lease_id           lob_a/workshop/database/creds/workshop-app/t3i85CnEjMlenWbvmJux8SI6
lease_duration     3m
lease_renewable    true
password           A1a-ksrpiyz4tRKmxsRI
username           v-token-workshop-a-kVYT30h6l3e1y
```


Now, use the last set of credentials to connect to the local MySQL server with a command like this:
`mysql -u <username> -p`
Replace `<user_name>` with the one generated from the previous command and provide the generated password when prompted. Then press the '' or `<return>` key on your keyboard.

You should then see text like that below and be given a `mysql>` prompt:
` Welcome to the MySQL monitor. Commands end with ; or \g. Your MySQL connection id is 7 Server version: 5.7.28 MySQL Community Server (GPL)

mysql> `

Verify that you can see two of the databases on the MySQL server by running this command:

```
show databases;
```
You should see this:
```
+--------------------+
| Database           |
+--------------------+
| information_schema |
| my_app             |
+--------------------+
2 rows in set (0.00 sec)
```

If you're curious about the my_app database, you can also run the following SQL commands:
```
use my_app;
show tables;
describe customers;
select first_name, last_name from customers;
```
But running these is not required to complete the challenge. If you get any errors while running those commands, it is probable that your credentials have expired.

Logout of the MySQL server by typing `\q` at the `mysql>` prompt. This should return you to the `root@vault-mysql-server:~#` prompt.

At least 3 minutes after you generated the credentials, try to connect to the MySQL server again, using the same username and password as before:
`mysql -u <username> -p`

You should get an error like `ERROR 1045 (28000): Access denied for user 'v-token-workshop-a-tUrh1Z6u5GwKn'@'localhost' (using password: YES).` If not, type `\q` to log out of MySQL and then try again.

This shows that Vault deleted the credentials from the MySQL database when the lease of the credentials expired after 3 minutes.

In the next challenge, you will learn how to renew and revoke database credentials.




* Renew and Revoke Database Credentials * 
https://www.vaultproject.io/api/system/leases/#renew-lease 
https://www.vaultproject.io/api/system/leases/#revoke-lease

In addition to using Vault's database secrets engine to generate credentials for databases, you can also use it to extend their lifetime or revoke them.

First, generate new credentials against the shorter role, "workshop-app", using the Vault CLI:

```
vault read lob_a/workshop/database/creds/workshop-app
```

This should return something like:
```
Key                Value
---                -----
lease_id           lob_a/workshop/database/creds/workshop-app/t3i85CnEjMlenWbvmJux8SI6
lease_duration     1m
lease_renewable    true
password           A1a-ksrpiyz4tRKmxsRI
username           v-token-workshop-a-kVYT30h6l3e1y
```

The lease on credentials returned by the database secrets engine can be manually renewed with a call like this:
```
vault write sys/leases/renew lease_id="<lease_id>" increment="120"
```
where you should replace `<lease_id>` with the lease_id returned by the previous command. In this case, we are extending the life of the credentials by 2 minutes.

This command should return something like this:
```
Key                Value
---                -----
lease_id           lob_a/workshop/database/creds/workshop-app/jr0to1AfDqE2eiPl2GzYShzR
lease_duration     2m
lease_renewable    true

```

Now, examine the current lease with a command like this:
```
vault write sys/leases/lookup lease_id="<lease_id>"
```
where you should replace `<lease_id>` with the lease_id returned by either of the last two commands. This should return something like:
```
Key             Value
---             -----
expire_time     2019-12-12T17:52:41.267656422Z
id              lob_a/workshop/database/creds/workshop-app/5PfygQTgMTwJNCEVqujwaVLS
issue_time      2019-12-12T17:49:41.267656019Z
last_renewal    <nil>
renewable       true
ttl             1m45s
```
The `ttl` will tell you the remaining time to live of the lease and the credentials. When the lease expires, Vault will delete the credentials from MySQL.

Extending the lease will only work if the lease has not yet expired. Additionally, the lease on the credentials cannot be extended beyond the original time of their creation plus the duration given by the `max_ttl` parameter of the role. If either of these conditions apply, you will get an error.

For instance, if you try to lookup a lease that has already expired, you will get an `invalid lease` error. If you try to extend the lease with an increment of 600 seconds (10 minutes), you will see an error like:

```
WARNING! The following warnings were returned from Vault:
    * TTL of "10m0s" exceeded the effective max_ttl of "2m17s";
    TTL value is capped accordingly
```


Finally, let's explore how you can revoke database credentials. First, generate a new set of credentials:
```
vault read lob_a/workshop/database/creds/workshop-app
```
Then revoke the credentials:
```
vault write sys/leases/revoke lease_id="<lease_id>"
```
replacing `<lease_id>` with the one returned with the generated credentials. You should see "Success! Data written to: `sys/leases/revoke`" returned.

Try to login to the MySQL server with the revoked credentials:
```
mysql -u <username> -p
```
replacing `<username>` with the generated username and providing the generated password when prompted. You should see a mesage including` "ERROR 1045 (28000): Access denied for user"`.

