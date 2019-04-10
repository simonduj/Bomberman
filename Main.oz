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
   Grid = {GUI.buildWindow}
   Players = Input.bombers

   ID = bomber(id:1 color:red name:'Antoine')
   ID2 = bomber(id:2 color:red name:'Antoine')

   Player = {PlayerManager.playerGenerator {Nth Players 1} ID}
   Player2 = {PlayerManager.playerGenerator {Nth Players 2} ID2}

   Bomber = {GUI.initPlayer Grid ID}
   Bomber2 = {GUI.initPlayer Grid ID2}
   %{GUI.spawnPlayer Grid Player 4 2}
   %{Browser.browse ID}
end
