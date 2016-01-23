export PATH := ./sourcemod/scripting/:$(PATH)
export SPCOMP := spcomp

.PHONY: all clean

all: teams.smx

%.smx: %.sp
	$(SPCOMP) $<

clean:
	rm *.smx
