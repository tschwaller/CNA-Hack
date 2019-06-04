#!/bin/bash

# you need to install opsmanager first on Ops Manager

# wget https://github.com/pivotal-cf/om/releases/download/1.1.0/om-linux
# chmod a+x om-linux
# sudo mv om-linux /usr/local/bin/om

OPSMANAGER=opsman.corp.local
ADMIN=admin
PASSWORD=VMware1!
UAA_FQDN=pks.corp.local
PKS_FQDN=pks.corp.local

GUID=$(om -t https://${OPSMANAGER} -u "${ADMIN}" -p "${PASSWORD}" -k curl -p /api/v0/deployed/products -s | jq '.[] | select(.installation_name | contains("pivotal-container-service"))  | .guid' | tr -d '""')
ADMIN_SECRET=$(om -t https://${OPSMANAGER} -u "${ADMIN}" -p "${PASSWORD}" -k curl -p /api/v0/deployed/products/${GUID}/credentials/.properties.pks_uaa_management_admin_client -s | jq '.credential.value.secret' | tr -d '""')

uaac target https://${UAA_FQDN}:8443 --skip-ssl-validation
uaac token client get admin -s "${ADMIN_SECRET}"
uaac user add vmware --emails admin@${PKS_FQDN} -p ${PASSWORD}
uaac user add demo --emails demo@${PKS_FQDN} -p ${PASSWORD}
uaac member add pks.clusters.admin admin
uaac member add pks.clusters.manage demo
