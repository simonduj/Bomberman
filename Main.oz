functor
import
   GUI
   Input
   PlayerManager
   Browser
export
   turnByTurn:TurnByTurn
   simultaneous:Simultaneous
define
   TurnByTurn
   Simultaneous
   Grid
   Players
   NbPlayers
   ID
   PlayerPort
   Bomber
   Colors
   Player2Port
   ID2
   Bomber2
   InitStream
   BoardPort
   T P T2 P2
in
   %% Implement your controller here
   Colors = Input.colorsBombers
   NbPlayers = Input.nbBombers
   %Grid = {GUI.buildWindow}
   Players = Input.bombers


   ID = bomber(id:1 color:Colors.1 name:'Antoine')
   ID2 = bomber(id:2 color:red name:'Simon')

   %We can deal with the random order here : PlayerPort = ID or ID2 randomly 
   PlayerPort = {PlayerManager.playerGenerator {Nth Players 1} ID} 
   Player2Port = {PlayerManager.playerGenerator {Nth Players 2} ID2}

   %Creat the port for the board and init. of the board
   BoardPort  = {GUI.portWindow}
   {Send BoardPort buildWindow}
   {Send BoardPort initPlayer(ID)}
   {Send BoardPort initPlayer(ID2)}
   {Send PlayerPort assignSpawn(pt(x:2 y:2))}
   {Send Player2Port assignSpawn(pt(x:12 y:6))}
   {Send PlayerPort spawn(T P)}
   {Send Player2Port spawn(T2 P2)}
   {Send BoardPort spawnPlayer(ID P)}
   {Send BoardPort spawnPlayer(ID2 P2)}

   for I in 1..20 do
      {Time.delay 500}%Just to see the dynamic
      local ID Action in 
         %The first player play
         if I mod 2 == 0 then % Alternate on Player1 and Player2
            {Send PlayerPort doaction(ID Action)}
            case Action 
               of move(Pos) then {Send BoardPort movePlayer(ID Pos)}
               [] bomb(Pos) then skip %DO SOMETHING FOR THAT
            end
         %The second player play   
         else
            {Send Player2Port doaction(ID Action)}
            case Action
               of move(Pos) then {Send BoardPort movePlayer(ID Pos)}
               [] bomb(Pos) then skip %DO SOMETHING FOR THAT
            end 
         end 
      end 
   end 

   proc{TurnByTurn A}
      A=true % A is here just to avoid compilation error, this is considered as empty
      
   end 

   proc{Simultaneous A}
      A=true % A is here just to avoid compilation error, this is considered as empty
   end 
end
