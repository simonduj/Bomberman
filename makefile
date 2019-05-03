# ----------------------------
# group nb 40
# 12431600 : Grollinger Antoine
# 57521400 : Dujardin Simon
# ----------------------------

UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Linux)

all : Input.ozf PlayerManager.ozf GUI.ozf compilePlayers Main.ozf run

compilePlayers : PlayerManager.ozf Players.ozf GUI.ozf Main.ozf

players : Players.ozf

clean : 
	rm GUI.ozf Input.ozf Main.ozf Player000name.ozf PlayerManager.ozf

cleanMain :
	rm Main.ozf

Input.ozf : 
	$(ozc) -c Input.oz

PlayerManager.ozf : 
	$(ozc) -c PlayerManager.oz

Players.ozf : 
	$(ozc) -c Player000name.oz
	$(ozc) -c Player040Advanced.oz



GUI.ozf : 
	$(ozc) -c GUI.oz 

Main.ozf : 
	$(ozc) -c Main.oz

run : 
	$(ozengine) Main.ozf

else

ozc = /Applications/Mozart2.app/Contents/Resources/bin/ozc
ozengine = /Applications/Mozart2.app/Contents/Resources/bin/ozengine

all : Input.ozf PlayerManager.ozf GUI.ozf compilePlayers Main.ozf run

compilePlayers : PlayerManager.ozf Players.ozf GUI.ozf Main.ozf

players : Players.ozf

clean : 
	rm GUI.ozf Input.ozf Main.ozf Player000name.ozf PlayerManager.ozf

cleanMain :
	rm Main.ozf

Input.ozf : 
	$(ozc) -c Input.oz

PlayerManager.ozf : 
	$(ozc) -c PlayerManager.oz

Players.ozf : 
	$(ozc) -c Player000name.oz
	$(ozc) -c Player040Advanced.oz



GUI.ozf : 
	$(ozc) -c GUI.oz 

Main.ozf : 
	$(ozc) -c Main.oz

run : 
	$(ozengine) Main.ozf

endif
