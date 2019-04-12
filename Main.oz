functor
import
   GUI
   Input
   PlayerManager
   Browser
define
   Grid
   Players
   NbPlayers
   ID
   Player
   Bomber
   Colors
   Player2
   ID2
   Bomber2
in
   %% Implement your controller here
   Colors = Input.colorsBombers
   NbPlayers = Input.nbBombers
   %Grid = {GUI.buildWindow}
   Players = Input.bombers

   ID = bomber(id:1 color:red name:'Antoine')
   ID2 = bomber(id:2 color:blue name:'Simon')

   Player = {PlayerManager.playerGenerator {Nth Players 1} ID}
   Player2 = {PlayerManager.playerGenerator {Nth Players 2} ID2}

   {GUI.treat [buildWindow initPlayer(ID) initPlayer(ID2) spawnPlayer(ID pt(x:2 y:2)) 
      spawnPlayer(ID2 pt(x:12 y:6)) hidePlayer(ID) displayWinner(ID2)] _ players(1:Player 2:Player2)}
   %{GUI.treat initPlayer(ID2) Grid Player2}

   %{Browser.browse Bomber2}
   %{GUI.treat spawnPlayer(ID pt(x:4 y:2)) Grid Player}
   %{Browser.browse ID}
end
