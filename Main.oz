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
   InitStream
   BoardPort
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

   %Init. of the board
   BoardPort  = {GUI.portWindow}
   {Send BoardPort buildWindow}
   {Send BoardPort initPlayer(ID)}
   {Send BoardPort initPlayer(ID2)}
   {Time.delay 2000}
   {Send BoardPort spawnPlayer(ID pt(x:2 y:2))}
   {Time.delay 2000}
   {Send BoardPort spawnPlayer(ID2 pt(x:12 y:6))}


end
