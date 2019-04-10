functor
import
   GUI
   Input
   PlayerManager
   Browser
define
   Port
   Window
   Players
   CreatePlayers
   NbPlayers
   Z
   PlayerList
   ID
in
   %% Implement your controller here
   NbPlayers = Input.nbBombers
   %Port = {GUI.portWindow}
   Port = {GUI.buildWindow}
   Players = Input.bombers
   fun{CreatePlayers N}
    if N == 0 then nil
    else {PlayerManager.playerGenerator {Nth Players N} {GUI.initPlayer Port N}}|{CreatePlayers N-1} end
  end
  {CreatePlayers NbPlayers ID}
  {Browser.browse ID}
end
