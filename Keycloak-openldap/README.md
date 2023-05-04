# keycloak-openldap

This project  setup a secure system with [`Keycloak`](https://www.keycloak.org). Furthermore, the users will be loaded into `Keycloak` from [`OpenLDAP`](https://www.openldap.org) server.

## Prerequisites
You should use Linux (debian) or Windows WSL to setup this project

- [`Docker`](https://www.docker.com/)
- [`Docker-Compose`](https://docs.docker.com/compose/install/)
- [`jq`](https://stedolan.github.io/jq)
- **Ldap utils**  
   - sudo apt -y install ldap-utils

## Start Environment

- Open a terminal and inside `keycloak-openldap` root folder run
  ```
  docker-compose up -d
  ```

- Wait for Docker containers to be up and running. To check it, run
  ```
  docker-compose ps
  ```

# Run the setup Script

- In a terminal and inside `keycloak-openldap` root folder run
- **You need to have `ldap-utils` installed on your linux distro to run `ldapadd & ldapsearch`**
  ```
  ./firstRun.sh
  ```

# Created Users and Roles
> - The initial script 
>   - will setup everything and add 2 users to LDAP/Keycloak
>     - {user : 'bgates', password: '123', role: ['USER']}
>     - {user : 'sjobs', password: '123', role: ['USER','ADMIN']}
>   - will print into console some valuable information for Keycloak auth using OAuth2.0's Authorization Code Grant.


## Authorization code grant

The [authorization code grant](https://tools.ietf.org/html/rfc6749#section-1.3.1)
is the most commonly used because it is optimized for server-side applications,
where source code is not publicly exposed, and Client Secret confidentiality can be maintained.
This is a redirection-based flow, which means that the application must be capable of interacting
with the user-agent (i.e. the user's web browser) and receiving API authorization codes that
are routed through the user-agent.

## Using phpldapadmin website to check your ldap

- Access https://localhost:6443

- Login with the credentials
  ```
  Login DN: cn=admin,dc=kps,dc=com
  Password: admin
  ```

## Login Keycloak

- Access http://localhost:8081/admin/

- Login with the credentials
  ```
  Username: admin
  Password: admin
  ```

## A normal JWT after successfully login into Keycloak should look like this.
```
{
    "exp": 1683193180,
    "iat": 1683192880,
    "auth_time": 1683191597,
    "jti": "dba56ed6-84e1-4cb2-834e-08bb31c52482",
    "iss": "http://localhost:8081/realms/mbr-kps-service",
    "aud": "account",
    "sub": "67f4241e-0e82-4249-8d1d-a774d3b5963e",
    "typ": "Bearer",
    "azp": "mbr-kps-service",
    "session_state": "130e3e4f-530c-4e49-b89a-b869ecd31ce5",
    "acr": "0",
    "allowed-origins": [
        "http://localhost:9080"
    ],
    "realm_access": {
        "roles": [
            "default-roles-mbr-kps-service",
            "offline_access",
            "uma_authorization"
        ]
    },
    "resource_access": {
        "mbr-kps-service": {
            "roles": [
                "USER"
            ]
        },
        "account": {
            "roles": [
                "manage-account",
                "manage-account-links",
                "view-profile"
            ]
        }
    },
    "scope": "openid email profile",
    "sid": "130e3e4f-530c-4e49-b89a-b869ecd31ce5",
    "email_verified": false,
    "name": "Bill Gates gates",
    "preferred_username": "bgates",
    "given_name": "Bill Gates",
    "family_name": "gates"
}
```


# Stop and delete all (WARNING !!!! **ALL IMAGES AND CONTAINERS ON YOUR DOCKER**)

  ```
  docker-compose down
  docker rmi -f $(docker images -a -q)
  docker system prune --all
  
  ```
