*The Vault CLI*

The Vault Command Line Interface (CLI) allows you to interact with Vault servers.


## Basic commands

Check the version of Vault running on your machine:

```
vault version
```
See the list of Vault CLI commands:

```
vault
```
Get help for the "vault secrets" command:

```
vault secrets -h
```
Note that you can also use the "-help" and "--help" flags instead of "-h".

Get help for the "vault read" command:

```
vault read -h
```
Scroll back up to get a feeling for how you would read secrets from Vault.



##Your First Secret

 https://www.vaultproject.io/docs/concepts/dev-server/  For more on Dev mode 
 https://www.vaultproject.io/docs/secrets/kv/kv-v2/  For info about kv2


There are three tabs to use in this challenge: Vault CLI, Vault Dev Server, and Vault UI.

Vault servers can be run in "dev" and "production" modes. You can see this by getting help for the "vault server" CLI command:

Select the "Vault CLI" tab and run the following:

```
vault server -h
```
Scroll back up to see information about the two modes.

Select the "Vault Dev Server" tab

Let's run Vault in Dev Server mode. The simpest command to do this would be "vault server -dev", but we want to set the initial root token to "root" and make the Vault server bind to all IP addresses. So, please run this instead:

```
vault server -dev -dev-listen-address=0.0.0.0:8200 -dev-root-token-id=root
```
Select the "Vault UI" tab.

Log into the Vault UI with Method set to Token and Token set to root.

Select the "Vault CLI" tab.

Write a secret to the KV v2 secrets engine that the Vault dev server automatically mounted:
```
vault kv put secret/my-first-secret age=<age>
```
where `<age>` is your age.

Alternatively, you could create this secret in the Vault UI by selecting the "secret/" KV v2 secrets engine on the "Secrets" tab, clicking the "Create secret +" button, specifying "my-first-secret" as the path, "age" as the secret's first key, and your age as the corresponding value, and then finally clicking the "Save" button.

In the Vault UI tab, select the "secret/" KV v2 secrets engine, select the "my-first-secret" secret, and click the eye icon to see your age.

If you lied about your age, you can correct it in the Vault UI by clicking the "Create new version +" button, or with the Vault CLI by repeating the "vault kv put" command with your real age. Don't worry, nobody else can see it!


*The Vault API*
https://www.vaultproject.io/api-docs/ 
In this challenge, you will use the Vault HTTP API.

On the "Vault CLI" tab, retrive the health of the Vault server by running this command:

```curl http://localhost:8200/v1/sys/health | jq```
That should bring back a nicely formatted JSON document indicating that your server is initialized and unsealed.

Now, retrieve your "my-first-secret" secret with this command (on a single line):

```curl --header "X-Vault-Token: root" http://localhost:8200/v1/secret/data/my-first-secret | jq```

This should bring back a JSON document showing your age and metadata about the secret including its version.




*Run a Production Server*


https://www.vaultproject.io/docs/configuration/ for information on configuring a Vault server.
https://www.vaultproject.io/docs/commands/operator/init/ for information on initializing a Vault server. 
https://www.vaultproject.io/docs/concepts/seal/ for information on the sealing and unsealing of Vault servers.


Let's run a production Vault sever.

A production Vault server gets its configuration from a configuration file. Open the vault-config.hcl configuration file on the "Vault Configuration" tab to see what your server will use.

On the "Vault Server" tab, run a Vault server that uses the configuration file:

```
vault server -config=/vault/config/vault-config.hcl
```
Since that tab is now running the Vault server, you'll run the rest of the CLI commands on the "Vault CLI" tab.

Initialize the new server, indicating that you want to use one unseal key:
```
vault operator init -key-shares=1 -key-threshold=1
```
This gives you back an unseal key and an initial root token. Please save these for further use within this track.

In order to use most Vault commands, you need to set the "VAULT_TOKEN" environment variable, using the initial root token that the "init" command returned:
```
export VAULT_TOKEN=<root_token>
```
being sure to use your own root token instead of `<root_token>`.

Please also add this to your ".profile" file with this command:

```
echo "export VAULT_TOKEN=$VAULT_TOKEN" >> /root/.profile
```
You next need to unseal your Vault server, providing the unseal key that the "init" command returned:
```
vault operator unseal
```
This will return the status of the server which should show that "Initialized" is "true" and that "Sealed` is "false".

To check the status of your Vault server at any time, you can run the vault status command. If it shows that "Sealed" is "true", re-run the vault operator unseal command.

Finally, log into the Vault UI with your root token. If you have problems, double-check that you ran all of the above commands.

Don't forget to save your root token and unseal key!


* Use the KV V2 Secrets Engine * 
Now that you have a Vault production server running (in the background), you can mount a secrets engine and write secrets to it.

The setup script for this challenge has exported your root token for you from your ".profile" file.

First, you can mount an instance of the KV v2 secrets engine on the default path, "kv":
```
vault secrets enable -version=2 kv
```

Next, write a secret to your new secrets engine:
```
vault kv put kv/a-secret value=1234
```
Feel free to specify your own secret number instead of 1234.

Login to the Vault UI with your root token and verify that the secret "a-secret" under the "kv" secrets engine has the value you provided by clicking its eye icon.

Change the value in the UI by clicking the "Create new version +" button, typing a new value in the field with the dots, and clicking the "Save" button. Click the eye icon for the secret to validate the change.

Still in the Vault UI, select the History menu for the secret, select "Version 1", and click the eye icon again to see the original value.


* Use the Userpass Auth Method * 
Now that you have a running production Vault server with a KV v2 secrets engine mounted, it's time to learn how to authenticate users.

The setup script for this challenge has exported your root token for you from your ".profile" file.

First, enable the Userpass auth method:
```
vault auth enable userpass
```
Next, add yourself as a Vault user without any policies:
```
vault write auth/userpass/users/<name> password=<pwd>
```
Be sure to specify an actual username for <name> and a password for <pwd> without the angle brackets.

Now, you can sign into the Vault UI by selecting the Username method and providing your username and password.

You can also login with the Vault CLI:
```
vault login -method=userpass username=<name> password=<pwd>
```
Both of these login methods give you a Vault token with Vault's default policy that grants some very limited capabilities. A yellow warning message tells us that we currently have the `VAULT_TOKEN` environment variable set and that we should either unset it or set it to the new token. Let's unset it:

```
unset VAULT_TOKEN
```
To confirm that your new token is being used, run this command:
```
vault token lookup
```
You will see that the display_name of the current token is "userpass-<name>" where <name> is your username and that the only policy listed for the token is the "default" policy.

Try to read the secret you wrote to the KV v2 secrets engine in the last challenge:
```
vault kv get kv/a-secret
```
You will get an error message because your token is not authorized to read any secrets yet. That is because Vault policies are "deny by default", meaning that a token can only read or write a secret if it is explicitly given permission to do so by one of its policies.

In the next challenge, you'll add a policy to your username that will allow you to read and write some secrets.

*  Use Vault Policies * 
Now that you have the Userpass authentication method configured, you can add policies to give different users access to different secrets.

The setup script for this challenge has exported your root token for you from your ".profile" file.

You already created a username for yourself to use with the Userpass auth method. Now, create a second user with the same command you used before, selecting a different username and password:
```
vault write auth/userpass/users/<name> password=<pwd>
```
Next, edit the two policies on the "Vault Policies" tab, user-1-policy.hcl and user-2-policy.hcl. In user-1-policy.hcl, set all occurences of <user> to your own username. In user-2-policy.hcl, set all occurences of <user> to the username of the user you just added.

user-1-policy.hcl: 

```
path "kv/data/<user>/*" {
  capabilities = ["create", "update", "read", "delete"]
}
path "kv/delete/<user>/*" {
  capabilities = ["update"]
}
path "kv/metadata/<user>/*" {
  capabilities = ["list", "read", "delete"]
}
path "kv/destroy/<user>/*" {
  capabilities = ["update"]
}

# Additional access for UI
path "kv/metadata" {
  capabilities = ["list"]
}

```
user-2-policy.hcl: 
```
path "kv/data/<user>/*" {
  capabilities = ["create", "update", "read", "delete"]
}
path "kv/delete/<user>/*" {
  capabilities = ["update"]
}
path "kv/metadata/<user>/*" {
  capabilities = ["list", "read", "delete"]
}
path "kv/destroy/<user>/*" {
  capabilities = ["update"]
}

# Additional access for UI
path "kv/metadata" {
  capabilities = ["list"]
}
```


Save both files by clicking the disk icon above the files. (Do that once for each file.)

Next, you are going to add the policies to the Vault server:
```
vault policy write <user_1> /vault/policies/user-1-policy.hcl
vault policy write <user_2> /vault/policies/user-2-policy.hcl
```
replacing <user_1> and <user_2> with the usernames you are using.

Now, you can assign the new policies to the users by updating the policies assigned to the users:
```
vault write auth/userpass/users/<user_1>/policies policies=<user_1>
vault write auth/userpass/users/<user_2>/policies policies=<user_2>
```
again replacing `<user_1>` and `<user_2>` with the usernames you are using.

Now, let's see what happens when you log into the Vault UI as the two different users.

Log in as yourself (the first user you created). Remember to specify the login method as "Username".

Click on the kv secrets engine. You should see the secret you previously created called "a-secret". But if you select it, you'll see a "Not Authorized" message.

Click on the "kv" breadcrumb to go back to the previous screen.

Click the "Create secret +" button, enter <user>/age for the path, "age" for the key in the "Version data" section of the screen, and your age for the value associated with that key. Be sure to replace <user> with the username of the logged in user. Then click the "Save" button. You should be allowed to do this.

Logout and log back in as the second user. Try to access the first user's secret. You should not be able to.

Now, while still logged in as the second user, repeat the above steps to create a secret, specifying the second user's name for <user> in the path. You should be allowed to do this.

If you would like to see what happens when using the Vault CLI, you can run unset VAULT_TOKEN, login as each user with vault login -method=userpass username=<user> password=<pwd>, and then try commands like the following:
```
vault kv get kv/<user>/age
vault kv put kv/<user>/weight weight=150
```
These will succeed when <user> matches the username of the logged in user and fail when it does not.

The bottom line for this challenge is that Vault protects each user's secrets from other users.

Congratulations on finishing the entire track!

Exit*