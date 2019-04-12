# ----------------------------
# group nb 40
# 12431600 : Grollinger Antoine
# 57521400 : Dujardin Simon
# ----------------------------

UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Linux)

all : Input.ozf PlayerManager.ozf GUI.ozf Main.ozf run

run : Main.ozf 
	ozengine Main.ozf

Main.ozf : Main.oz GUI.ozf Input.ozf PlayerManager.ozf
	ozc -c Main.oz

GUI.ozf : GUI.oz
	ozc -c GUI.oz

Input.ozf : Input.oz
	ozc -c Input.oz

PlayerManager.ozf : PlayerManager.oz
	ozc -c PlayerManager.oz

clean : 
	mkdir tmp && mv Player000bomber.ozf Projet2019util.ozf tmp
	rm *.ozf
	mv tmp/* . && rm -rf tmp

cleanMain :
	rm Main.ozf

else

ozc = /Applications/Mozart2.app/Contents/Resources/bin/ozc
ozengine = /Applications/Mozart2.app/Contents/Resources/bin/ozengine

all : Input.ozf PlayerManager.ozf GUI.ozf Main.ozf run

compile : PlayerManager.ozf Players.ozf GUI.ozf Main.ozf

compilePlayers : Players.ozf

clean : 
	mkdir tmp && mv Player000bomber.ozf Projet2019util.ozf tmp
	rm *.ozf
	mv tmp/* . && rm -rf tmp

cleanMain :
	rm Main.ozf

Input.ozf : 
	$(ozc) -c Input.oz

PlayerManager.ozf : 
	$(ozc) -c PlayerManager.oz

Players.ozf : 
	$(ozc) -c Player000name.oz 

GUI.ozf : 
	$(ozc) -c GUI.oz 

Main.ozf : 
	$(ozc) -c Main.oz

run : 
	$(ozengine) Main.ozf

endif
