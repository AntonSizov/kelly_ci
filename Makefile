KELLY-DIR=kelly
KELLY-BRANCH=mongodb_storage
KELLY-REL=$(KELLY-DIR)/rel/kelly/

FUNNEL-DIR=funnel
FUNNEL-BRANCH=billy-preview
FUNNEL-REL=$(FUNNEL-DIR)/funnel_mini

JUST-DIR=just
JUST-BRANCH=master
JUST-REL=$(JUST-DIR)/just_mini

BILLY-DIR=billy
BILLY-BRANCH=mongodb_storage
BILLY-REL=$(BILLY-DIR)/rel/billy/

K1API-DIR=k1api
K1API-BRANCH=develop
K1API-REL=$(K1API-DIR)/rel/k1api

SMPPSIM-DIR=SMPPSim


RMQ-DIR=./rmq

all: $(RMQ-DIR) $(SMPPSIM-DIR) $(K1API-REL) $(KELLY-REL) $(JUST-REL) $(FUNNEL-REL) $(BILLY-REL)
	@./ci.sh test-k1api

$(KELLY-DIR):
	@echo -n Cloning kelly into $(KELLY-DIR)...
	@git clone --branch=$(KELLY-BRANCH) --depth=100 --quiet git://github.com/PowerMeMobile/kelly.git $(KELLY-DIR)
	@echo OK

$(KELLY-REL): $(KELLY-DIR)
	@echo Building kelly...
	@make -C $(KELLY-DIR)

$(JUST-DIR):
	@echo -n Cloning just into $(JUST-DIR)...
	@git clone --branch=$(JUST-BRANCH) --depth=100 --quiet git://github.com/PowerMeMobile/just_mini_rel.git $(JUST-DIR)
	@echo OK

$(JUST-REL): $(JUST-DIR)
	@echo Building just...
	@make -C $(JUST-DIR)

$(FUNNEL-DIR):
	@echo -n Cloning funnel into $(FUNNEL-DIR)...
	@git clone --branch=$(FUNNEL-BRANCH) --depth=100 --quiet git@github.com:PowerMeMobile/funnel_mini_rel.git $(FUNNEL-DIR)
	@echo OK

$(FUNNEL-REL): $(FUNNEL-DIR)
	@echo Building funnel...
	@make -C $(FUNNEL-DIR)

$(BILLY-DIR):
	@echo -n Cloning billy into $(BILLY-DIR)...
	@git clone --branch=$(BILLY-BRANCH) --depth=100 --quiet git@github.com:PowerMeMobile/billy.git $(BILLY-DIR)
	@echo OK

$(BILLY-REL): $(BILLY-DIR)
	@echo Building billy...
	@make -C $(BILLY-DIR)

$(K1API-DIR):
	@echo -n Cloning k1api into $(K1API-DIR)...
	@git clone --branch=$(K1API-BRANCH) --depth=100 --quiet git@github.com:PowerMeMobile/k1api.git $(K1API-DIR)
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
	eval "wget https://dl.dropbox.com/u/85105941/SMPPSim.tar.gz"
	tar xzf ./SMPPSim.tar.gz
	rm SMPPSim.tar.gz
	chmod +x $(SMPPSIM-DIR)/startsmppsim.sh
	cp ./smppsim.props $(SMPPSIM-DIR)/conf/

$(RMQ-DIR):
	@mkdir ./rmq