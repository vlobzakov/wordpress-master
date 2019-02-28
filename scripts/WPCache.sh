#!/bin/bash -e

pgcache=false;
objectcache=false;
edgeportCDN=false;

ARGUMENT_LIST=(
    "pgcache"
    "objectcache"
    "edgeportCDN"
    "REDIS_HOST"
    "REDIS_PASS"
    "CDN_URL"
    "CDN_ORI"
)

# read arguments
opts=$(getopt \
    --longoptions "$(printf "%s:," "${ARGUMENT_LIST[@]}")" \
    --name "$(basename "$0")" \
    --options "" \
    -- "$@"
)
eval set --$opts

while [[ $# -gt 0 ]]; do
    case "$1" in
        --pgcache)
            pgcache=$2
            shift 2
            ;;

        --objectcache)
            objectcache=$2
            shift 2
            ;;

        --edgeportCDN)
            edgeportCDN=$2
            shift 2
            ;;

        --REDIS_HOST)
            REDIS_HOST=$2
            shift 2
            ;;

        --REDIS_PASS)
            REDIS_PASS=$2
            shift 2
            ;;

        --CDN_URL)
            CDN_URL=$2
            shift 2
            ;;

        --CDN_ORI)
            CDN_ORI=$2
            shift 2
            ;;

        *)
            break
            ;;
    esac
done

W3TC_OPTION_SET="wp w3-total-cache option set"
LSCWP_OPTION_SET="wp lscache-admin set_option"
lOG="/var/log/run.log"

COMPUTE_TYPE=$(grep "COMPUTE_TYPE=" /etc/jelastic/metainf.conf | cut -d"=" -f2)

if [[ ${COMPUTE_TYPE} == *"llsmp"* || ${COMPUTE_TYPE} == *"litespeed"* ]] ; then
	wp plugin install litespeed-cache --activate --path=${SERVER_WEBROOT}
        WPCACHE='lscwp';
elif [[ ${COMPUTE_TYPE} == *"lemp"* || ${COMPUTE_TYPE} == *"nginx"* ]] ; then
	wp plugin install w3-total-cache --activate --path=${SERVER_WEBROOT}
        WPCACHE="w3tc";
else
        echo 'Compute type is not defined';
	exit;
fi

function checkCdnStatus () {
[[ $WPCACHE == 'w3tc' ]] && CDN_ENABLE_CMD="/usr/local/bin/wp w3-total-cache option set cdn.enabled true --type=boolean"
[[ $WPCACHE == 'lscwp' ]] && CDN_ENABLE_CMD="/usr/local/bin/wp lscache-admin set_option cdn true"
cat > ~/checkCdnStatus.sh <<EOF
#!/bin/bash
  status=\$(curl \$1 -k -s -f -o /dev/null && echo "SUCCESS" || echo "ERROR")
    if [ \$status = "SUCCESS" ]
    then
      ${CDN_ENABLE_CMD} --path=${SERVER_WEBROOT} &>> /var/log/run.log
      /usr/local/bin/wp cache flush --path=${SERVER_WEBROOT} &>> /var/log/run.log
      crontab -l | sed "/checkCdnStatus/d" | crontab -
    fi
EOF
chmod +x ~/checkCdnStatus.sh
crontab -l | { cat; echo "* * * * * ~/checkCdnStatus.sh ${CDN_URL}"; } | crontab
}


if [ $pgcache == 'true' ] ; then
  case $WPCACHE in
    w3tc)
	  $W3TC_OPTION_SET pgcache.enabled true --type=boolean --path=${SERVER_WEBROOT} &>> $lOG
          $W3TC_OPTION_SET pgcache.file.nfs true --type=boolean --path=${SERVER_WEBROOT} &>> $lOG
          ;;
    lscwp)
          $LSCWP_OPTION_SET cache_browser true --path=${SERVER_WEBROOT} &>> $lOG
          $LSCWP_OPTION_SET css_http2 true --path=${SERVER_WEBROOT} &>> $lOG
          $LSCWP_OPTION_SET js_http2 true --path=${SERVER_WEBROOT} &>> $lOG
          $LSCWP_OPTION_SET optm_qs_rm true --path=${SERVER_WEBROOT} &>> $lOG
          $LSCWP_OPTION_SET optm_emoji_rm true --path=${SERVER_WEBROOT} &>> $lOG
          $LSCWP_OPTION_SET esi_enabled true --path=${SERVER_WEBROOT} &>> $lOG
          ;;
     *)
	  echo "-- $WPCACHE cache is not supported" &>> $lOG
          exit 1
          ;;
  esac
fi

if [ $objectcache == 'true' ] ; then
  case $WPCACHE in
    w3tc)
          $W3TC_OPTION_SET objectcache.enabled true --type=boolean --path=${SERVER_WEBROOT} &>> /var/log/run.log
          $W3TC_OPTION_SET objectcache.engine redis --path=${SERVER_WEBROOT} &>> /var/log/run.log
          $W3TC_OPTION_SET objectcache.redis.servers ${REDIS_HOST}:6379 --path=${SERVER_WEBROOT} &>> /var/log/run.log
          $W3TC_OPTION_SET objectcache.redis.password ${REDIS_PASS} --path=${SERVER_WEBROOT} &>> /var/log/run.log
          ;;
    lscwp)
          $LSCWP_OPTION_SET cache_object true --path=${SERVER_WEBROOT} &>> /var/log/run.log
          $LSCWP_OPTION_SET cache_object_kind true --path=${SERVER_WEBROOT} &>> /var/log/run.log
          $LSCWP_OPTION_SET cache_object_host ${REDIS_HOST} --path=${SERVER_WEBROOT} &>> /var/log/run.log
          $LSCWP_OPTION_SET cache_object_port 6379 --path=${SERVER_WEBROOT} &>> /var/log/run.log
          ;;
     *)
          echo "-- $WPCACHE cache is not supported" &>> $lOG
          exit 1
          ;;
  esac
fi

if [ $edgeportCDN == 'true' ] ; then
  case $WPCACHE in
    w3tc)
	  checkCdnStatus;
	  $W3TC_OPTION_SET cdn.enabled false --type=boolean --path=${SERVER_WEBROOT} &>> /var/log/run.log
          $W3TC_OPTION_SET cdn.engine mirror --path=${SERVER_WEBROOT} &>> /var/log/run.log
          $W3TC_OPTION_SET cdn.mirror.domain ${CDN_URL} --path=${SERVER_WEBROOT} &>> /var/log/run.log
          ;;
    lscwp)
	  checkCdnStatus;
          $LSCWP_OPTION_SET cdn false --path=${SERVER_WEBROOT} &>> /var/log/run.log
          $LSCWP_OPTION_SET cdn_ori "//${CDN_ORI}/" --path=${SERVER_WEBROOT} &>> /var/log/run.log
          ;;
     *)
          echo "-- $WPCACHE cache is not supported" &>> $lOG
          exit 1
          ;;
  esac
fi
