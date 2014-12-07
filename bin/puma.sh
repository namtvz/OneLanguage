#! /bin/sh

PUMA_CONFIG_FILE=/var/www/OneLanguage/current/config/puma.rb
PUMA_PID_FILE=/var/www/OneLanguage/shared/tmp/pids/puma.pid
PUMA_SOCKET=/var/www/OneLanguage/shared/tmp/sockets/puma.sock

# check if puma process is running
puma_is_running() {
  if [ -S $PUMA_SOCKET ] ; then
    if [ -e $PUMA_PID_FILE ] ; then
      if pgrep -F $PUMA_PID_FILE > /dev/null ; then
        return 0
      else
        echo "No puma process found"
      fi
    else
      echo "No puma pid file found"
    fi
  else
    echo "No puma socket found"
  fi

  return 1
}

case "$1" in
  start)
    echo "Starting puma..."
      rm -f $PUMA_SOCKET
      if [ -e $PUMA_CONFIG_FILE ] ; then
        NEED_UPDATE_ONLINE=true bundle exec puma -C $PUMA_CONFIG_FILE
      else
        NEED_UPDATE_ONLINE=true bundle exec puma
      fi

    echo "done"
    ;;

  stop)
    echo "Stopping puma..."
      kill -9 `cat $PUMA_PID_FILE`
      rm -f $PUMA_PID_FILE
      rm -f $PUMA_SOCKET

    echo "done"
    ;;

  restart)
    if puma_is_running ; then
      echo "Hot-restarting puma..."
      kill -12 `cat $PUMA_PID_FILE`

      echo "Doublechecking the process restart..."
      sleep 5
      if puma_is_running ; then
        echo "done"
        exit 0
      else
        echo "Puma restart failed :/"
      fi
    fi

    echo "Trying cold reboot"
    sh bin/puma.sh start
    ;;

  *)
    echo "Usage: script/puma.sh {start|stop|restart}" >&2
    ;;
esac