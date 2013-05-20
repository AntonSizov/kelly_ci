
PWD=`pwd`

KELLY-DIR=kelly
KELLY-REP="git://github.com/PowerMeMobile/kelly.git"
KELLY-BRANCH=master
KELLY-REL=$(KELLY-DIR)/rel/kelly/

FUNNEL-DIR=funnel
FUNNEL-REP="git@github.com:PowerMeMobile/funnel_mini_rel.git"
FUNNEL-BRANCH=master
FUNNEL-REL=$(FUNNEL-DIR)/funnel_mini

JUST-DIR=just
JUST-REP="git://github.com/PowerMeMobile/just_mini_rel.git"
JUST-BRANCH=master
JUST-REL=$(JUST-DIR)/just_mini

BILLY-DIR=billy
BILLY-REP="git@github.com:PowerMeMobile/billy.git"
BILLY-BRANCH=mongodb_storage
BILLY-REL=$(BILLY-DIR)/rel/billy/

K1API-DIR=k1api
K1API-REP="git@github.com:PowerMeMobile/k1api.git"
K1API-BRANCH=develop
K1API-REL=$(K1API-DIR)/rel/k1api

KANNEL-SRC-DIR=gateway-1.4.3
KANNEL-SRC=gateway-1.4.3.tar.gz
KANNEL-SRC-URL="http://www.kannel.org/download/1.4.3/gateway-1.4.3.tar.gz"
KANNEL-DIR=kannel
KANNEL-CONF=./etc/kannel.conf

SMPPSIM-DIR=SMPPSim

RMQ-DIR=./rmq

LOG-DIR=./log

all: kelly-test billy-test funnel-test k1api-test

get-env: $(LOG-DIR) $(RMQ-DIR) $(SMPPSIM-DIR) $(K1API-REL) $(KELLY-REL) $(JUST-REL) $(FUNNEL-REL) $(BILLY-REL)

kelly-test: get-env
	@./ci.sh test-kelly

billy-test: get-env
	@./ci.sh test-billy

k1api-test: get-env
	@./ci.sh test-k1api

funnel-test: env-force-stop $(LOG-DIR) $(RMQ-DIR) $(SMPPSIM-DIR) $(KELLY-REL) $(JUST-REL) $(FUNNEL-REL) $(KANNEL-DIR) $(KANNEL-CONF)
	@./ci.sh test-funnel

env-force-stop:
	@./ci.sh force-stop

$(KANNEL-CONF):
	@./etc/perform_kannel_conf $(PWD)

$(KANNEL-DIR): $(KANNEL-SRC-DIR)
	@mkdir $(KANNEL-DIR)
	@make -C $(KANNEL-SRC-DIR) prefix=../$(KANNEL-DIR) install
	@mkdir ./$(KANNEL-DIR)/log

$(KANNEL-SRC-DIR): $(KANNEL-SRC)
	@tar xzf ./$(KANNEL-SRC)
	@cd ./$(KANNEL-SRC-DIR) && ./configure && cd ..
	@make -C $(KANNEL-SRC-DIR)

$(KANNEL-SRC):
	@wget $(KANNEL-SRC-URL)

$(KELLY-DIR):
	@echo -n Cloning kelly into $(KELLY-DIR)...
	@git clone --branch=$(KELLY-BRANCH) --depth=1 --quiet $(KELLY-REP) $(KELLY-DIR)
	@echo OK

$(KELLY-REL): $(KELLY-DIR)
	@echo Building kelly...
	@make -C $(KELLY-DIR)

$(JUST-DIR):
	@echo -n Cloning just into $(JUST-DIR)...
	@git clone --branch=$(JUST-BRANCH) --depth=1 --quiet $(JUST-REP) $(JUST-DIR)
	@echo OK

$(JUST-REL): $(JUST-DIR)
	@echo Building just...
	@make -C $(JUST-DIR)
	@cp -r $(JUST-REL)/log $(JUST-REL)/log_
	@cp -r $(JUST-REL)/data $(JUST-REL)/data_

$(FUNNEL-DIR):
	@echo -n Cloning funnel into $(FUNNEL-DIR)...
	@git clone --branch=$(FUNNEL-BRANCH) --depth=1 --quiet $(FUNNEL-REP) $(FUNNEL-DIR)
	@echo OK

$(FUNNEL-REL): $(FUNNEL-DIR)
	@echo Building funnel...
	@make -C $(FUNNEL-DIR)
	@cp -r $(FUNNEL-REL)/log $(FUNNEL-REL)/log_
	@cp -r $(FUNNEL-REL)/data $(FUNNEL-REL)/data_

$(BILLY-DIR):
	@echo -n Cloning billy into $(BILLY-DIR)...
	@git clone --branch=$(BILLY-BRANCH) --depth=1 --quiet $(BILLY-REP) $(BILLY-DIR)
	@echo OK

$(BILLY-REL): $(BILLY-DIR)
	@echo Building billy...
	@make -C $(BILLY-DIR)

$(K1API-DIR):
	@echo -n Cloning k1api into $(K1API-DIR)...
	@git clone --branch=$(K1API-BRANCH) --depth=1 --quiet $(K1API-REP) $(K1API-DIR)
	@echo OK

$(K1API-REL): $(K1API-DIR)
	@echo Building k1api...
	@make -C $(K1API-DIR)

clean-working-dir:
	@echo -n Cleaning working directory...
	@rm -rf $(KELLY-DIR)
	@rm -rf $(FUNNEL-DIR)
	@rm -rf $(JUST-DIR)
	@rm -rf $(BILLY-DIR)
	@rm -rf $(K1API-DIR)
	@echo OK

$(SMPPSIM-DIR):
	@echo -n Fetching smppsim...
	@eval "wget https://dl.dropbox.com/u/85105941/SMPPSim.tar.gz"
	@tar xzf ./SMPPSim.tar.gz
	@rm SMPPSim.tar.gz
	@chmod +x $(SMPPSIM-DIR)/startsmppsim.sh
	@cp ./etc/smppsim.props $(SMPPSIM-DIR)/conf/
	@echo OK

$(RMQ-DIR):
	@mkdir ./rmq

$(LOG-DIR):
	@mkdir ./log