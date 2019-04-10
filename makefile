# ----------------------------
# group nb 40
# noma1 : name1 Antoine Grollinger
# noma2 : name2 Simon Dujardin
# ----------------------------

ozc = /Applications/Mozart2.app/Contents/Resources/bin/ozc
ozengine = /Applications/Mozart2.app/Contents/Resources/bin/ozengine

all : Input.ozf PlayerManager.ozf GUI.ozf Main.ozf Run.ozf

compile : PlayerManager.ozf Players.ozf GUI.ozf Main.ozf

compilePlayers : Players.ozf

run : Run.ozf

clean : 
	rm *.ozf

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

Run.ozf : 
	$(ozengine) Main.ozf
