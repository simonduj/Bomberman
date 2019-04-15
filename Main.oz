functor
import
   GUI
   Input
   PlayerManager
   Browser
export
   turnByTurn:TurnByTurn
   simultaneous:Simultaneous
   treatBomb:TreatBomb
   fireProp:FireProp
   initGame:InitGame
   getValue:GetValue
define
   FirePropAux
   GetValueAux
   GetValue
   InitGame
   FireProp
   TreatBomb
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
   %%%%% HELPER %%%%%
   proc{TurnByTurn A}
      skip
   end 

   proc{Simultaneous A}
      skip
   end 
   fun{GetValueAux L Y}
      if Y == 1 then L.1
      else
         {GetValueAux L.2 Y-1}
      end
   end
   fun{GetValue M X Y}
      if X == 1 then {GetValueAux M.1 Y}
      else
         {GetValue M.2 X-1 Y}
      end
   end
   proc{InitGame}
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
      {Send Player2Port info(spawnPlayer(T P))}
      {Send PlayerPort info(spawnPlayer(T2 P2))}
      {Send BoardPort spawnPlayer(ID P)}
      {Send BoardPort spawnPlayer(ID2 P2)}
   end 
   proc{FireProp Pos}
      {Send BoardPort spawnFire(Pos)} %first spawnFire where the bomb was dropped
      {FirePropAux Pos 0 Input.fire}
      {FirePropAux Pos 1 Input.fire}
      {FirePropAux Pos 2 Input.fire}
      {FirePropAux Pos 3 Input.fire}
   end 
   %Proc for propagating fire with :
   %Pos : Pos where bomb exploded
   %D : 0-N 1-E 2-S 3-W
   %R : Distance for propagation ("Stop condition")
   % /!\ /!\ /!\ When we say X+1, it means one step in the north direction /!\ /!\ /!\ 
   proc{FirePropAux Pos D R}
      local NEXT in
      if R == 0 then skip 
      elseif D == 0 then
         NEXT = {GetValue Input.map Pos.y+1 Pos.x}
         %PROPAGATE NORTH
         if NEXT==1 then
            skip
            %STOP PROPAGATING
         elseif NEXT==2 then
            skip
            %DEAL WITH POINT BOX
         elseif NEXT==3 then
            skip
            %DEAL WITH BONUS BOX
         else 
            {Send BoardPort spawnFire(pt(x:Pos.x y:Pos.y+1))}
            {FirePropAux pt(x:Pos.x y:Pos.y+1) 0 R-1}
         end 
      elseif D == 1 then
         NEXT = {GetValue Input.map Pos.y Pos.x+1}
         if NEXT==1 then
            skip
            %STOP PROPAGATING
         elseif NEXT==2 then
            skip
            %DEAL WITH POINT BOX
         elseif NEXT==3 then
            skip
            %DEAL WITH BONUS BOX
         else
            {Send BoardPort spawnFire(pt(x:Pos.x+1 y:Pos.y))}
            {FirePropAux pt(x:Pos.x+1 y:Pos.y) 1 R-1}
         end 
      elseif D == 2 then
         NEXT = {GetValue Input.map Pos.y-1 Pos.x}
         if NEXT==1 then
            skip
            %STOP PROPAGATING
         elseif NEXT==2 then
            skip
            %DEAL WITH POINT BOX
         elseif NEXT==3 then
            skip
            %DEAL WITH BONUS BOX
         else
            {Send BoardPort spawnFire(pt(x:Pos.x y:Pos.y-1))}
            {FirePropAux pt(x:Pos.x y:Pos.y-1) 2 R-1}
         end 
      else
         NEXT = {GetValue Input.map Pos.y Pos.x-1}
         if NEXT==1 then
            skip
            %STOP PROPAGATING
         elseif NEXT==2 then
            skip
            %DEAL WITH POINT BOX
         elseif NEXT==3 then
            skip
            %DEAL WITH BONUS BOX
         else
            {Send BoardPort spawnFire(pt(x:Pos.x-1 y:Pos.y))}
            {FirePropAux pt(x:Pos.x-1 y:Pos.y) 3 R-1}
         end 
      end 
      end
   end 

   {InitGame}
   {Time.delay 2500} %Waiting for the board to be full screened

   for I in 1..1000 do %1000 turn /!\ SHOULD BE REPLACED BY CONDITION ABOUT END OF THE GAME
      {Time.delay 250}%Just to see the dynamic
      local ID Action in 
         %The first player play
         if I mod 2 == 0 then % Alternate on Player1 and Player2
            {Send PlayerPort doaction(ID Action)}
            case Action 
               of move(Pos) then 
                  {Send BoardPort movePlayer(ID Pos)}
                  {Send Player2Port info(movePlayer(ID Pos))}
               [] bomb(Pos) then 
                  %Fire's propagation
                  {FireProp Pos}
            end
         %The second player play   
         else
            {Send Player2Port doaction(ID Action)}
            case Action
               of move(Pos) then 
                  {Send BoardPort movePlayer(ID Pos)}
                  {Send PlayerPort info(movePlayer(ID Pos))}
               [] bomb(Pos) then 
                  %Fire's propagation
                  {FireProp Pos} 
            end 
         end 
      end 
   end 
end
