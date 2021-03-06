#!/bin/bash -ex

chmod +x om-cli/om-linux
CMD=./om-cli/om-linux

METRICS_GUID=`$CMD -t https://$OPS_MGR_HOST -k -u $OPS_MGR_USR -p $OPS_MGR_PWD curl -p "/api/v0/deployed/products" -x GET | jq '.[] | select(.type | contains("p-metrics")) | .installation_name' | tr -d '"'`

METRICS_MANIFEST=`$CMD -t https://$OPS_MGR_HOST -k -u $OPS_MGR_USR -p $OPS_MGR_PWD curl -p "/api/v0/staged/products/$METRICS_GUID/manifest" -x GET`

MAXIMUS_IP=`echo $METRICS_MANIFEST | jq '.manifest.instance_groups[] | select(.name | contains("maximus")) | .properties.maximus.public_hostname' | tr -d '"'`

DIRECTOR_CONFIG=$(cat <<-EOF
{
  "metrics_ip": "$MAXIMUS_IP"
}
EOF
)

$CMD -t https://$OPS_MGR_HOST -k -u $OPS_MGR_USR -p $OPS_MGR_PWD configure-bosh \
            -d "$DIRECTOR_CONFIG"
