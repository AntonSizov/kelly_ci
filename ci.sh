#!/bin/bash

# export PATH=/opt/mongodb/bin/:$PATH

# SMSBOX Settings
SMSB_HOST=localhost
SMSB_PORT=13003
SMSBOX_USER=test
SMSBOX_PSW=test
SMSBOX_FROM=
SMSBOX_TO=%2B375443066532
SEND_MT_SMS_TEXT=test-funnel
SEND_MT_SMS_DLR_MASK=31
SEND_MT_SMS_REQ="http://$SMSB_HOST:$SMSB_PORT/cgi-bin/sendsms?username=$SMSBOX_USER&password=$SMSBOX_PSW&from=$SMSBOX_FROM&to=$SMSBOX_TO&text=$SEND_MT_SMS_TEXT&dlr-mask=$SEND_MT_SMS_DLR_MASK"

MONGODB_PATH=`which mongo`; if [ ! "$MONGODB_PATH" ]; then echo "mongodb is not in path"; exit 1; fi
export RABBITMQ_MNESIA_BASE=./rmq/mnesia
export RABBITMQ_LOG_BASE=./rmq/log
export RABBITMQ_PID_FILE=./rmq/pid

SMPPSIM_HOST="localhost"
SMPPSIM_PORT="8071"

SMPPSIM_ADDR="http://$SMPPSIM_HOST:$SMPPSIM_PORT"

SCRIPT=`basename $0`

KELLY_DIR="kelly"
KELLY_REL="$KELLY_DIR/rel/kelly/"

FUNNEL_DIR="funnel"
FUNNEL_REL="$FUNNEL_DIR/funnel_mini"

JUST_DIR="just"
JUST_REL="$JUST_DIR/just_mini"

BILLY_DIR="billy"
BILLY_REL="$BILLY_DIR/rel/billy/"

K1API_DIR="k1api"
K1API_REL="$K1API_DIR/rel/k1api"


BB=`which bearerbox`; if [ ! "$BB" ]; then echo kannel bearerbox not installed; exit 1; fi
SB=`which smsbox`; if [ ! "$SB" ]; then echo kannel smsbox not installed; exit 1; fi

smppsim-start(){
    if [ "$SMPPSIM_RES" = "200" ]; then
        echo "Smppsim is already running!"
        exit 1
    fi
	echo -n "Starting smppsim..."
	cd ./SMPPSim/
	./startsmppsim.sh > /dev/null 2>&1 &
	cd ..
	echo "OK"
}

smppsim-stop(){
	SMPPSIM_PID=`ps -ef | grep smppsim.jar | grep -v grep | awk '{ print $2 }'`
    if [ "$SMPPSIM_PID" = "" ]; then
        echo "Smppsim is not running!"
	else
		echo -n "Stopping smppsim..."
		kill -15 $SMPPSIM_PID
		echo "OK"
    fi
}

smppsim-clean(){
    if [ "$SMPPSIM_RES" = "200" ]; then
        echo "Smppsim is running! Stop it before clean."
        exit 1
    fi
	echo -n "Cleaning smppsim..."
	rm -f ./SMPPSim/smppsim?.log.?
	rm -f ./SMPPSim/sme_decoded.capture
	rm -f ./SMPPSim/smppsim_decoded.capture
	echo "OK"
}

kelly-start(){
	echo -n "Starting kelly..."
	$KELLY_REL/bin/kelly start
	sleep 5
	KELLY_RESP=`$KELLY_REL/bin/kelly ping`
	if [ "$KELLY_RESP" != "pong" ]; then
		echo "Kelly said $KELLY_RESP. Expected pong"
		exit 1
	fi
	echo "OK"
	echo -n "Configuring kelly..."
	$KELLY_DIR/rel/files/http_conf.sh > ./log/kelly_http_conf.log 2>&1
	if [ "$?" != "0" ]; then
		echo "Error. See ./log/kelly_http_conf.log for more info"
		exit 1
	fi
	echo "OK"
}

kelly-stop(){
	echo -n "Stopping kelly..."
	RESULT=`$KELLY_REL/bin/kelly stop`
	if [ "$RESULT" = "ok" ]; then
	    echo "OK"
	else
	    echo "Kelly respond $RESULT. Expected ok."
		exit 1
	fi
}

kelly-clean(){
	echo -n "Cleaning kelly..."
	rm -rf $KELLY_REL/data/*
	rm -rf $KELLY_REL/log/*
	echo "OK"
}

just-start(){
	NAME="just"
	echo -n "Starting $NAME..."
	EXE=$JUST_REL/bin/$NAME
	$EXE start
	sleep 5
	RESP=`$EXE ping`
	if [ "$RESP" != "pong" ]; then
		echo "$NAME said $RESP. Expected pong"
		exit 1
	fi
	echo "OK"
}

just-stop(){
	echo -n "Stopping just..."
	RESULT=`$JUST_REL/bin/just stop`
	if [ "$RESULT" = "ok" ]; then
	    echo "OK"
	else
	    echo "Just respond $RESULT. Expected ok."
		exit 1
	fi
}

just-clean(){
	echo -n "Cleaning just..."
	rm -rf $JUST_REL/log
	rm -rf $JUST_REL/data
	cp -r $JUST_REL/data_ $JUST_REL/data
	cp -r $JUST_REL/log_ $JUST_REL/log
	echo "OK"
}

funnel-start(){
	NAME="funnel"
	echo -n "Starting $NAME..."
	EXE=$FUNNEL_REL/bin/$NAME
	$EXE start
	sleep 5
	RESP=`$EXE ping`
	if [ "$RESP" != "pong" ]; then
		echo "$NAME said $RESP. Expected pong"
		exit 1
	fi
	echo "OK"
}

funnel-stop(){
	NAME="funnel"
	echo -n "Stopping $NAME..."
	RESULT=`$FUNNEL_REL/bin/$NAME stop`
	if [ "$RESULT" = "ok" ]; then
	    echo "OK"
	else
	    echo "$NAME respond $RESULT. Expected ok."
		exit 1
	fi
}

funnel-clean(){
	NAME="funnel"
	echo -n "Cleaning $NAME..."
	rm -rf $FUNNEL_REL/log
	rm -rf $FUNNEL_REL/data
	cp -r $FUNNEL_REL/data_ $FUNNEL_REL/data
	cp -r $FUNNEL_REL/log_ $FUNNEL_REL/log
	echo "OK"
}

billy-start(){
	NAME="billy"
	echo -n "Starting $NAME..."
	EXE=$BILLY_REL/bin/$NAME
	$EXE start
	sleep 5
	RESP=`$EXE ping`
	if [ "$RESP" != "pong" ]; then
		echo "$NAME said $RESP. Expected pong"
		exit 1
	fi
	echo "OK"
	echo -n "Configuring billy..."
	$BILLY_DIR/rel/files/http_conf.sh > ./log/billy_http_conf.log 2>&1
	if [ "$?" != "0" ]; then
		echo "Error. See ./log/billy_http_conf.log for more info"
		exit 1
	fi
	echo "OK"
}

billy-stop(){
	NAME="billy"
	echo -n "Stopping $NAME..."
	RESULT=`$BILLY_REL/bin/$NAME stop`
	if [ "$RESULT" = "ok" ]; then
	    echo "OK"
	else
	    echo "$NAME respond $RESULT. Expected ok."
		exit 1
	fi
}

billy-clean(){
	NAME="billy"
	echo -n "Cleaning $NAME..."
	rm -rf $BILLY_REL/log/*
	rm -rf $BILLY_REL/data/*
	echo "OK"
}

k1api-start(){
	NAME="k1api"
	echo -n "Starting $NAME..."
	EXE=$K1API_REL/bin/$NAME
	$EXE start
	sleep 5
	RESP=`$EXE ping`
	if [ "$RESP" != "pong" ]; then
		echo "$NAME said $RESP. Expected pong"
		exit 1
	fi
	echo "OK"
}

k1api-stop(){
	NAME="k1api"
	echo -n "Stopping $NAME..."
	RESULT=`$K1API_REL/bin/$NAME stop`
	if [ "$RESULT" = "ok" ]; then
	    echo "OK"
	else
	    echo "$NAME respond $RESULT. Expected ok."
		exit 1
	fi
}

k1api-clean(){
	NAME="k1api"
	echo -n "Cleaning $NAME..."
	rm -rf $K1API_REL/log/*
	rm -rf $K1API_REL/Mnesia.k1api@127.0.0.1
	rm -rf $K1API_REL/cache.dets
	echo "OK"
}

mongo-start(){
	echo "Starting MongoDB...OK"
}

mongo-stop(){
	echo "Stopping MongoDB...OK"
}

mongo-clean(){
	echo -n "Cleaning mongodb..."
	RESULT=`mongo localhost/kelly --quiet --eval 'r=db.dropDatabase();if (r.dropped=="kelly" && r.ok==1) {"ok"} else {"err"}'`
	if [ "$RESULT" != "ok" ]; then
		echo "error [kelly]"
		exit 1
	fi
	RESULT=`mongo localhost/billydb --quiet --eval 'r=db.dropDatabase();if (r.dropped=="billydb" && r.ok==1) {"ok"} else {"err"}'`
	if [ "$RESULT" != "ok" ]; then
		echo "error [billydb]"
		exit 1
	fi
	echo "OK"
}

rabbit-start(){
	RMQ_PID=`ps -ef | grep rabbit | grep beam | awk '{ print $2 }'`
	if [ "$RMQ_PID" != "" ]; then
		echo "RabbitMQ already running!"
		exit 1
	fi
	echo -n "Starting RabbitMQ..."
	rabbitmq-server -detached > /dev/null 2>&1
	sleep 3
	echo "OK"
}

rabbit-stop(){
	RMQ_PID=`ps -ef | grep rabbit | grep beam | awk '{ print $2 }'`
	if [ "$RMQ_PID" = "" ]; then
		echo "RabbitMQ not running!"
	fi
	echo -n "Stopping RabbitMQ..."
	kill -9 $RMQ_PID
	echo "OK"
}

rabbit-clean(){
	echo -n "Cleaning RabbitMQ..."
	rm -rf $RABBITMQ_MNESIA_BASE
	rm -rf $RABBITMQ_LOG_BASE
	echo "OK"
}

kannel-start(){
	echo -n "Starting Kannel..."
	$(pwd)"/kannel/sbin/bearerbox" -V 1 -d $(pwd)"/etc/kannel.conf"
	$(pwd)"/kannel/sbin/smsbox" -V 1 -d $(pwd)"/etc/kannel.conf"
	echo OK
}

kannel-stop(){
	echo -n "Stopping Kannel..."
	echo OK
}

env-start(){
	rabbit-start
	smppsim-start
	just-start
	billy-start
	funnel-start
	k1api-start
	kelly-start
	kannel-start
}

env-stop(){
	kannel-stop
	kelly-stop
	k1api-stop
	funnel-stop
	billy-stop
	just-stop
	smppsim-stop
	rabbit-stop
}
env-clean(){
	rabbit-clean
	smppsim-clean
	just-clean
	billy-clean
	funnel-clean
	k1api-clean
	kelly-clean
}

lookup_smppsim_logs_for_mes(){
	echo lookup for $2
	RES=`grep $2 ./SMPPSim/smppsim_decoded.capture | grep DELIVRD | wc -l`
	echo Lookup smppsim log command returned: $RES
	if [[ "$RES" != "$1" ]]; then
		echo ERROR: SMPPSIM did not send receipt to just
		exit 1
	fi
}

case "$1" in
	test-kelly)
		mongo-start
		echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
		echo "%%%%%%%%%%%%% START KELLY HTTP TESTS %%%"
		echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
		mongo-clean
		env-clean
		env-start
		make -C ./kelly api-test
		if [ "$?" != "0" ]; then
			env-stop
			exit 1
		fi
		env-stop
		mongo-stop
		;;
	test-billy)
		mongo-start
		echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
		echo "%%%%%%%%%%%%% START BILLY HTTP TESTS %%%"
		echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
		env-clean
		mongo-clean
		billy-start
		mongo-clean
		make -C ./billy api-test
		if [ "$?" != "0" ]; then
			env-stop
			exit 1
		fi
		billy-stop
		mongo-stop
		;;
	test-k1api)
		TEST_CASES="mt-prepaid-test mt-postpaid-test mo-test"
		mongo-start
		for test in $TEST_CASES; do
			echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
			echo "%%%%%%% START ONEAPI TEST CASE ($test) %%%"
			echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
			mongo-clean
			env-clean
			env-start
			make -C ./k1api $test
			if [ "$?" != "0" ]; then
				env-stop
				exit 1
			fi
			env-stop
		done
		mongo-stop
		;;
	test-funnel)
		echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
		echo "%%%%%%% START FUNNEL TESTS %%%"
		echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"

		#env clean
		mongo-clean
		rabbit-clean
		smppsim-clean
		just-clean
		funnel-clean
		kelly-clean


		#env start
		rabbit-start
		smppsim-start
		just-start
		funnel-start
		kelly-start
		kannel-start

		echo -n Waiting for connection between kannel and funnel...;sleep 2;echo OK

		REQ_RESULT=$(curl -s -D - "$SEND_MT_SMS_REQ" -o /dev/null | grep '202 Accepted')
		if [ "$REQ_RESULT" == "" ]; then
			echo Bad response
			exit 1
		else
			echo Message successfully sent
		fi

		# loogup for kannel sms id
		sleep 1
		ACC_LOG=./kannel/log/access.log
		TEXT=test-funnel
		ID=`grep 'Sent SMS' $ACC_LOG | grep $TEXT | tail -1 | awk '{print $9}'`
		echo Kannel sent sms id: $ID
		ESCAPED_PATTERN=`printf "%q" $ID`

		echo -n Waiting for sent message registered in logs...
		sleep 10
		echo OK

		# loogup for delivrd in smppsim logs
		lookup_smppsim_logs_for_mes 1 'test-funnel'
		if [ "$?" != "0" ]; then
			echo Lookup error
			env-stop
			exit 1
		fi

		# lookup for delivrd in kannel acc_log
		KANNEL_DELIVERY=`grep $ESCAPED_PATTERN $ACC_LOG | grep DELIVRD`
		if [[ "$KANNEL_DELIVERY" == "" ]];then
			echo Delivery receipt not found in kannel access log
			exit 1
		else
			echo Delivery receipt found in kannel access log
		fi

		echo TEST OK
		./ci.sh force-stop
		mongo-clean
		exit 0
		;;
	env-start)
		echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
		echo "%%%%%%%%%%%%%%%% START ENV ONLY %%%%%%%%%%"
		echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
		mongo-start
		mongo-clean
		env-clean
		env-start
		;;
	env-stop)
		env-stop
		;;
	force-stop)
		# stop erl instances
		ERL_INSTANCES="kelly k1api just billy funnel rabbit"
		for name in $ERL_INSTANCES; do
			echo "Force stopping $name..."
			PID=`ps ax -o pid= -o command= | grep $name | grep beam | awk '{ print $1 }'`
			if [ "$PID" != "" ]; then
				kill -9 $PID
			fi
		done

		# stop other instances
		INSTANCES="smsbox bearerbox"
		for name in $INSTANCES; do
			echo "Force stopping $name..."
			PID=`ps ax -o pid= -o command= | grep $name | grep sbin | awk '{ print $1 }'`
			if [ "$PID" != "" ]; then
				kill -9 $PID
			fi
		done

		smppsim-stop
		;;
    *)
        echo "Usage: $SCRIPT {test-kelly|test-billy|test-funnel|test-k1api|env-stop|env-start|force-stop}"
        exit 1
        ;;
esac

exit 0
