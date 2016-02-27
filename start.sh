#!/bin/sh

# Unset so that they don't interfere with command line argument values
unset SPARK_MASTER_PORT
unset SPARK_MASTER_WEBUI_PORT

# SPARK_MASTER_HOST is used to configure the address that workers and applications use to
# connect. If it is not the address of a local interface, then spark won't be able to bind
# to it. We can hack around this by setting the address to be an alias of a local interface
# address in the /etc/hosts file. This tricks spark (specifically, akka) into thinking that
# it is listening on the same address that others are connecting on.
if [ ! -z "$SPARK_MASTER_HOST" ]; then
  if ! grep -q "\s$SPARK_MASTER_HOST\s" /etc/hosts; then
    echo "Detected SPARK_MASTER_HOST=$SPARK_MASTER_HOST is not a local interface."
    ip=$(grep -i $(hostname) /etc/hosts | cut -d" " -f1)
    echo "Setting $SPARK_MASTER_HOST as alias for local interface $ip"
    sudo mungehosts -a "$ip  $SPARK_MASTER_HOST"
    cat /etc/hosts
  fi
fi

# Execute spark master in foreground
exec "$SPARK_HOME"/bin/spark-class org.apache.spark.deploy.master.Master \
  --port 7077 --webui-port 8080
