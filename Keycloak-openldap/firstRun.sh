#!/usr/bin/env bash

LDAP_HOST=${1:-localhost}
ldapadd -x -D "cn=admin,dc=kps,dc=com" -w admin -H ldap://$LDAP_HOST -f ldap/ldap-kps-com.ldif

KHP=${1:-"localhost:8081"}
AT=$(curl -s -X POST "http://$KHP/realms/master/protocol/openid-connect/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=admin" \
  -d 'password=admin' \
  -d 'grant_type=password' \
  -d 'client_id=admin-cli' | jq -r '.access_token')

curl -i -X POST "http://$KHP/admin/realms" \
  -H "Authorization: Bearer $AT" \
  -H "Content-Type: application/json" \
  -d '{"realm": "mbr-kps-service", "enabled": true}'

CI=$(curl -si -X POST "http://$KHP/admin/realms/mbr-kps-service/clients" \
  -H "Authorization: Bearer $AT" \
  -H "Content-Type: application/json" \
  -d '{"clientId": "mbr-kps-service", "directAccessGrantsEnabled": true, "redirectUris": ["http://localhost:9080/*"]}' \
  | grep -oE '[a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12}')


SERVICE_CLIENT_SECRET=$(curl -s -X POST "http://$KHP/admin/realms/mbr-kps-service/clients/$CI/client-secret" \
  -H "Authorization: Bearer $AT" | jq -r '.value')

curl -i -X POST "http://$KHP/admin/realms/mbr-kps-service/clients/$CI/roles" \
-H "Authorization: Bearer $AT" \
-H "Content-Type: application/json" \
-d '{"name": "USER"}'

curl -i -X POST "http://$KHP/admin/realms/mbr-kps-service/clients/$CI/roles" \
-H "Authorization: Bearer $AT" \
-H "Content-Type: application/json" \
-d '{"name": "ADMIN"}'

RI1=$(curl -s "http://$KHP/admin/realms/mbr-kps-service/clients/$CI/roles" \
  -H "Authorization: Bearer $AT" | jq -r '.[0].id')

RI2=$(curl -s "http://$KHP/admin/realms/mbr-kps-service/clients/$CI/roles" \
  -H "Authorization: Bearer $AT" | jq -r '.[1].id')

LDI=$(curl -si -X POST "http://$KHP/admin/realms/mbr-kps-service/components" \
  -H "Authorization: Bearer $AT" \
  -H "Content-Type: application/json" \
  -d '@ldap/ldap-config.json' \
  | grep -oE '[a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12}')

curl -i -X POST "http://$KHP/admin/realms/mbr-kps-service/user-storage/$LDI/sync?action=triggerFullSync" \
  -H "Authorization: Bearer $AT"

BGI=$(curl -s "http://$KHP/admin/realms/mbr-kps-service/users?username=bgates" \
  -H "Authorization: Bearer $AT"  | jq -r '.[0].id')

curl -i -X POST "http://$KHP/admin/realms/mbr-kps-service/users/$BGI/role-mappings/clients/$CI" \
  -H "Authorization: Bearer $AT" \
  -H "Content-Type: application/json" \
  -d '[{"id":"'"$RI1"'","name":"USER"}]'

SJI=$(curl -s "http://$KHP/admin/realms/mbr-kps-service/users?username=sjobs" \
  -H "Authorization: Bearer $AT"  | jq -r '.[0].id')

curl -i -X POST "http://$KHP/admin/realms/mbr-kps-service/users/$SJI/role-mappings/clients/$CI" \
  -H "Authorization: Bearer $AT" \
  -H "Content-Type: application/json" \
  -d '[{"id":"'"$RI1"'","name":"USER"},{"id":"'"$RI2"'","name":"ADMIN"}]'


echo
echo "======================================================="
echo "Redirect Uri=[http://localhost:9080/*]"
echo "REALM=mbr-kps-service"
echo "clientId=mbr-kps-service"
echo "SERVICE_CLIENT_SECRET=$SERVICE_CLIENT_SECRET"
echo "======================================================="
