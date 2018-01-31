PACKAGE         ?= partisan
VERSION         ?= $(shell git describe --tags)
BASE_DIR         = $(shell pwd)
ERLANG_BIN       = $(shell dirname $(shell which erl))
REBAR            = $(shell pwd)/rebar3
MAKE						 = make

.PHONY: rel deps test plots

all: compile

##
## Compilation targets
##

compile:
	$(REBAR) compile

clean: packageclean
	$(REBAR) clean

packageclean:
	rm -fr *.deb
	rm -fr *.tar.gz

##
## Test targets
##

perf:
	clear; pkill -9 beam.smp; pkill -9 epmd; exit 0
	./rebar3 ct --readable=false -v --suite=partisan_SUITE --case=default_manager_test --group=with_parallelism
	clear; pkill -9 beam.smp; pkill -9 epmd; exit 0
	./rebar3 ct --readable=false -v --suite=partisan_SUITE --case=default_manager_test --group=default

kill: 
	pkill -9 beam.smp; pkill -9 epmd; exit 0

check: kill test xref dialyzer

test: ct eunit

lint:
	${REBAR} as lint lint

eunit:
	${REBAR} as test eunit

ct:
	openssl rand -out test/partisan_SUITE_data/RAND 4096
	${REBAR} ct
	${REBAR} cover

shell:
	${REBAR} shell --apps partisan

tail-logs:
	tail -F priv/lager/*/log/*.log

logs:
	cat priv/lager/*/log/*.log

##
## Release targets
##

rel:
	${REBAR} release

stage:
	${REBAR} release -d

DIALYZER_APPS = kernel stdlib erts sasl eunit syntax_tools compiler crypto

include tools.mk
