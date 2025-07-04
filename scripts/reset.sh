#!/usr/bin/env bash

source ./scripts/core.sh

get_node_info_short
echo "=> Select a THORNode service to reset"
menu midgard midgard midgard-blockstore binance-smart-daemon thornode gaia-daemon ethereum-daemon-execution ethereum-daemon-beacon avalanche-daemon litecoin-daemon bitcoin-daemon base-daemon xrp-daemon
SERVICE=${MENU_SELECTED}

if node_exists; then
  echo
  warn "Found an existing THORNode, make sure this is the node you want to update:"
  display_status
  echo
fi

echo "=> Resetting service ${boldyellow}${SERVICE}${reset} of a THORNode named ${boldyellow}${NAME}${reset}"
echo
warn "Destructive command, be careful, your service data volume data will be wiped out and restarted to sync from scratch"
confirm

case ${SERVICE} in
  midgard)
    kubectl scale -n "${NAME}" --replicas=0 sts/midgard-timescaledb --timeout=5m
    kubectl wait --for=delete pods midgard-timescaledb-0 -n "${NAME}" --timeout=5m >/dev/null 2>&1 || true
    kubectl run -n "${NAME}" -it reset-midgard --rm --restart=Never --image=busybox --overrides='{"apiVersion": "v1", "spec": {"containers": [{"command": ["rm", "-rf", "/var/lib/postgresql/data/pgdata"], "name": "reset-midgard", "stdin": true, "stdinOnce": true, "tty": true, "image": "busybox", "volumeMounts": [{"mountPath": "/var/lib/postgresql/data", "name":"data"}]}], "volumes": [{"name": "data", "persistentVolumeClaim": {"claimName": "data-midgard-timescaledb-0"}}]}}'
    kubectl scale -n "${NAME}" --replicas=1 sts/midgard-timescaledb --timeout=5m
    kubectl delete -n "${NAME}" pod -l app.kubernetes.io/name=midgard
    ;;

  midgard-blockstore)
    kubectl scale -n "${NAME}" --replicas=0 sts/midgard --timeout=5m
    kubectl wait --for=delete pods midgard-0 -n "${NAME}" --timeout=5m >/dev/null 2>&1 || true
    kubectl run -n "${NAME}" -it reset-midgard --rm --restart=Never --image=busybox --overrides='{"apiVersion": "v1", "spec": {"containers": [{"command": ["sh", "-c", "rm -rf /blockstore/*"], "name": "reset-midgard", "stdin": true, "stdinOnce": true, "tty": true, "image": "busybox", "volumeMounts": [{"mountPath": "/blockstore", "name":"blockstore"}]}], "volumes": [{"name": "blockstore", "persistentVolumeClaim": {"claimName": "blockstore-midgard-0"}}]}}'
    kubectl scale -n "${NAME}" --replicas=1 sts/midgard --timeout=5m
    kubectl delete -n "${NAME}" pod -l app.kubernetes.io/name=midgard
    ;;

  thornode)
    kubectl scale -n "${NAME}" --replicas=0 deploy/thornode --timeout=5m
    kubectl wait --for=delete pods -l app.kubernetes.io/name=thornode -n "${NAME}" --timeout=5m >/dev/null 2>&1 || true
    kubectl run -n "${NAME}" -it recover-thord --rm --restart=Never --image=busybox --overrides='{"apiVersion": "v1", "spec": {"containers": [{"command": ["sh", "-c", "cd /root/.thornode/data && rm -rf bak && mkdir -p bak && mv application.db blockstore.db cs.wal evidence.db state.db tx_index.db bak/"], "name": "recover-thord", "stdin": true, "stdinOnce": true, "tty": true, "image": "busybox", "volumeMounts": [{"mountPath": "/root", "name":"data"}]}], "volumes": [{"name": "data", "persistentVolumeClaim": {"claimName": "thornode"}}]}}'
    kubectl scale -n "${NAME}" --replicas=1 deploy/thornode --timeout=5m
    ;;

  binance-smart-daemon)
    kubectl scale -n "${NAME}" --replicas=0 deploy/binance-smart-daemon --timeout=5m
    kubectl wait --for=delete pods -l app.kubernetes.io/name=binance-smart-daemon -n "${NAME}" --timeout=5m >/dev/null 2>&1 || true
    kubectl run -n "${NAME}" -it reset-binance-smart --rm --restart=Never --image=busybox --overrides='{"apiVersion": "v1", "spec": {"containers": [{"command": ["rm", "-rf", "/home/bsc/data/geth", "/home/bsc/data/keystore", "/home/bsc/data/snapshot.tar.zst", "/home/bsc/data/snapshot.tar.zst.aria2"], "name": "reset-binance-smart", "stdin": true, "stdinOnce": true, "tty": true, "image": "busybox", "volumeMounts": [{"mountPath": "/home/bsc/data", "name":"data"}]}], "volumes": [{"name": "data", "persistentVolumeClaim": {"claimName": "binance-smart-daemon"}}]}}'
    kubectl scale -n "${NAME}" --replicas=1 deploy/binance-smart-daemon --timeout=5m
    ;;

  gaia-daemon)
    kubectl scale -n "${NAME}" --replicas=0 deploy/gaia-daemon --timeout=5m
    kubectl wait --for=delete pods -l app.kubernetes.io/name=gaia-daemon -n "${NAME}" --timeout=5m >/dev/null 2>&1 || true
    kubectl run -n "${NAME}" -it reset-gaia --rm --restart=Never --image=busybox --overrides='{"apiVersion": "v1", "spec": {"containers": [{"command": ["sh", "-c", "rm -rf /root/.gaia/data"], "name": "reset-gaia", "stdin": true, "stdinOnce": true, "tty": true, "image": "busybox", "volumeMounts": [{"mountPath": "/root/.gaia", "name":"data"}]}], "volumes": [{"name": "data", "persistentVolumeClaim": {"claimName": "gaia-daemon"}}]}}'
    kubectl scale -n "${NAME}" --replicas=1 deploy/gaia-daemon --timeout=5m
    ;;

  ethereum-daemon-execution)
    kubectl scale -n "${NAME}" --replicas=0 deploy/ethereum-daemon --timeout=5m
    kubectl wait --for=delete pods -l app.kubernetes.io/name=ethereum-daemon -n "${NAME}" --timeout=5m >/dev/null 2>&1 || true
    kubectl run -n "${NAME}" -it reset-ethereum --rm --restart=Never --image=busybox --overrides='{"apiVersion": "v1", "spec": {"containers": [{"command": ["sh", "-c", "rm -rf /root/.ethereum"], "name": "reset-ethereum", "stdin": true, "stdinOnce": true, "tty": true, "image": "busybox", "volumeMounts": [{"mountPath": "/root", "name":"data"}]}], "volumes": [{"name": "data", "persistentVolumeClaim": {"claimName": "ethereum-daemon"}}]}}'
    kubectl scale -n "${NAME}" --replicas=1 deploy/ethereum-daemon --timeout=5m
    ;;

  ethereum-daemon-beacon)
    kubectl scale -n "${NAME}" --replicas=0 deploy/ethereum-daemon --timeout=5m
    kubectl wait --for=delete pods -l app.kubernetes.io/name=ethereum-daemon -n "${NAME}" --timeout=5m >/dev/null 2>&1 || true
    kubectl run -n "${NAME}" -it reset-ethereum --rm --restart=Never --image=busybox --overrides='{"apiVersion": "v1", "spec": {"containers": [{"command": ["sh", "-c", "rm -rf /root/beacon"], "name": "reset-ethereum", "stdin": true, "stdinOnce": true, "tty": true, "image": "busybox", "volumeMounts": [{"mountPath": "/root", "name":"data"}]}], "volumes": [{"name": "data", "persistentVolumeClaim": {"claimName": "ethereum-daemon"}}]}}'
    kubectl scale -n "${NAME}" --replicas=1 deploy/ethereum-daemon --timeout=5m
    ;;

  avalanche-daemon)
    kubectl scale -n "${NAME}" --replicas=0 deploy/avalanche-daemon --timeout=5m
    kubectl wait --for=delete pods -l app.kubernetes.io/name=avalanche-daemon -n "${NAME}" --timeout=5m >/dev/null 2>&1 || true
    kubectl run -n "${NAME}" -it reset-avalanche --rm --restart=Never --image=busybox --overrides='{"apiVersion": "v1", "spec": {"containers": [{"command": ["sh", "-c", "rm -rf /root/.avalanchego/db"], "name": "reset-avalanche", "stdin": true, "stdinOnce": true, "tty": true, "image": "busybox", "volumeMounts": [{"mountPath": "/root/.avalanchego", "name":"data"}]}], "volumes": [{"name": "data", "persistentVolumeClaim": {"claimName": "avalanche-daemon"}}]}}'
    kubectl scale -n "${NAME}" --replicas=1 deploy/avalanche-daemon --timeout=5m
    ;;

  litecoin-daemon)
    kubectl scale -n "${NAME}" --replicas=0 deploy/litecoin-daemon --timeout=5m
    kubectl wait --for=delete pods -l app.kubernetes.io/name=litecoin-daemon -n "${NAME}" --timeout=5m >/dev/null 2>&1 || true
    kubectl run -n "${NAME}" -it reset-litecoin --rm --restart=Never --image=busybox --overrides='{"apiVersion": "v1", "spec": {"containers": [{"command": ["sh", "-c", "rm -rf /home/litecoin/.litecoin/*"], "name": "reset-litecoin", "stdin": true, "stdinOnce": true, "tty": true, "image": "busybox", "volumeMounts": [{"mountPath": "/home/litecoin/.litecoin", "name":"data"}]}], "volumes": [{"name": "data", "persistentVolumeClaim": {"claimName": "litecoin-daemon"}}]}}'
    kubectl scale -n "${NAME}" --replicas=1 deploy/litecoin-daemon --timeout=5m
    ;;

  bitcoin-daemon)
    kubectl scale -n "${NAME}" --replicas=0 deploy/bitcoin-daemon --timeout=5m
    kubectl wait --for=delete pods -l app.kubernetes.io/name=bitcoin-daemon -n "${NAME}" --timeout=5m >/dev/null 2>&1 || true
    kubectl run -n "${NAME}" -it reset-bitcoin --rm --restart=Never --image=busybox --overrides='{"apiVersion": "v1", "spec": {"containers": [{"command": ["sh", "-c", "rm -rf /home/bitcoin/.bitcoin/*"], "name": "reset-bitcoin", "stdin": true, "stdinOnce": true, "tty": true, "image": "busybox", "volumeMounts": [{"mountPath": "/home/bitcoin/.bitcoin", "name":"data"}]}], "volumes": [{"name": "data", "persistentVolumeClaim": {"claimName": "bitcoin-daemon"}}]}}'
    kubectl scale -n "${NAME}" --replicas=1 deploy/bitcoin-daemon --timeout=5m
    ;;

  base-daemon)
    kubectl scale -n "${NAME}" --replicas=0 deploy/base-daemon --timeout=5m
    kubectl wait --for=delete pods -l app.kubernetes.io/name=base-daemon -n "${NAME}" --timeout=5m >/dev/null 2>&1 || true
    kubectl run -n "${NAME}" -it reset-base --rm --restart=Never --image=busybox --overrides='{"apiVersion": "v1", "spec": {"containers": [{"command": ["sh", "-c", "rm -rf /data/.ethereum"], "name": "reset-base", "stdin": true, "stdinOnce": true, "tty": true, "image": "busybox", "volumeMounts": [{"mountPath": "/data", "name":"data"}]}], "volumes": [{"name": "data", "persistentVolumeClaim": {"claimName": "base-daemon"}}]}}'
    kubectl scale -n "${NAME}" --replicas=1 deploy/base-daemon --timeout=5m
    ;;

  xrp-daemon)
    kubectl scale -n "${NAME}" --replicas=0 deploy/xrp-daemon --timeout=5m
    kubectl wait --for=delete pods -l app.kubernetes.io/name=xrp-daemon -n "${NAME}" --timeout=5m >/dev/null 2>&1 || true
    kubectl run -n "${NAME}" -it reset-xrp --rm --restart=Never --image=busybox --overrides='{"apiVersion": "v1", "spec": {"containers": [{"command": ["sh", "-c", "rm -rf /var/lib/rippled/db"], "name": "reset-xrp", "stdin": true, "stdinOnce": true, "tty": true, "image": "busybox", "volumeMounts": [{"mountPath": "/var/lib/rippled", "name":"data"}]}], "volumes": [{"name": "data", "persistentVolumeClaim": {"claimName": "xrp-daemon"}}]}}'
    kubectl scale -n "${NAME}" --replicas=1 deploy/xrp-daemon --timeout=5m
    ;;
esac
