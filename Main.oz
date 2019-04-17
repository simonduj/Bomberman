functor
import
   OS
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
   TurnByTurnAux
   IsTouched
   BinaryRand
   NewUnboundedList
   NewUnboundedMap
   CheckPos
   GetNextValue
   NextPos
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


   %%%%%%%%%%%%%%%%%%%%%%%%           %%%%%%%%%%%%%%%%%%%%%%%%
   %--------------------------HELPER--------------------------
   %%%%%%%%%%%%%%%%%%%%%%%%           %%%%%%%%%%%%%%%%%%%%%%%%


   proc{TurnByTurn A}
      skip
   end 

   proc{Simultaneous A}
      skip
   end 
   fun{IsTouched PosB PosP}
      local L in  %L = A list that enumerates all the touched Pos by bomb in PosB
         L=[PosB
            pt(x:PosB.x+1 y:PosB.y) pt(x:PosB.x+2 y:PosB.y) pt(x:PosB.x+3 y:PosB.y)
            pt(x:PosB.x-1 y:PosB.y) pt(x:PosB.x-2 y:PosB.y) pt(x:PosB.x-3 y:PosB.y)
            pt(x:PosB.x y:PosB.y+1) pt(x:PosB.x y:PosB.y+2) pt(x:PosB.x y:PosB.y+3)
            pt(x:PosB.x y:PosB.y-1) pt(x:PosB.x y:PosB.y-2) pt(x:PosB.x y:PosB.y-3)]
         {List.member PosP L}
      end
   end
   fun{BinaryRand}
      local N in 
         N={OS.rand}
         if N mod 2 == 0 then 0
         else 1
         end 
      end 
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
   fun{GetNextValue Pos D}
      if D==0 then {GetValue Input.map Pos.y+1 Pos.x}
      elseif D==1 then {GetValue Input.map Pos.y Pos.x+1}
      elseif D==2 then {GetValue Input.map Pos.y-1 Pos.x}
      else {GetValue Input.map Pos.y Pos.x-1}
      end 
   end 
   %Return the Next Position based on the direction D: N/E/S/O
   fun{NextPos Pos D}
      if D==0 then pt(x:Pos.x y:Pos.y+1)
      elseif D==1 then pt(x:Pos.x+1 y:Pos.y)
      elseif D==2 then pt(x:Pos.x y:Pos.y-1)
      else pt(x:Pos.x-1 y:Pos.y)
      end 
   end 
   proc{CheckPos Pos ID P}
      %HOW TO NOT COUNT MORE THAN 1 TIME THE POINT/BONUS
      local R in
      if {GetValue Input.map Pos.y Pos.x} == 2 then
         {Send P add(point 1 R)}
         {Send BoardPort hidePoint(Pos)}
         {Send BoardPort scoreUpdate(ID R)}
      elseif {GetValue Input.map Pos.y Pos.x} == 3 then 
         %DEAL WITH BONUS/BOMB
         if {BinaryRand}==0 then 
            {Send P add(bomb 1 R)}
            {Send BoardPort hideBonus(Pos)}
         else
            {Send P add(point 10 R)}
            {Send BoardPort hideBonus(Pos)}
            {Send BoardPort scoreUpdate(ID R)}
         end
      end 
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
   proc{FireProp Pos P}
      local R in 
      {Send PlayerPort info(bombExploded(Pos))}
      {Send Player2Port info(bombExploded(Pos))}
      {Send BoardPort spawnFire(Pos)} %first spawnFire where the bomb was dropped
      {Send P add(bomb 1 R)}
      {FirePropAux Pos 0 Input.fire}
      {FirePropAux Pos 1 Input.fire}
      {FirePropAux Pos 2 Input.fire}
      {FirePropAux Pos 3 Input.fire}
      end 
   end 
   %Proc for propagating fire with :
   %Pos : Pos where bomb exploded
   %D : direction 
   %R : Distance for propagation ("Stop condition")
   % /!\ /!\ /!\ When we say X+1, it means one step in the north direction /!\ /!\ /!\ 
   proc{FirePropAux Pos D R}
      local NEXT in
      if R == 0 then skip 
      else
         NEXT = {GetNextValue Pos D}
         if NEXT==1 then
            skip
            %STOP PROPAGATING
         elseif NEXT==2 then
            {Send BoardPort hideBox({NextPos Pos D})}
            {Send PlayerPort info(boxRemoved({NextPos Pos D}))}
            {Send Player2Port info(boxRemoved({NextPos Pos D}))}
            {Send BoardPort spawnPoint({NextPos Pos D})}
         elseif NEXT==3 then
            skip
            {Send BoardPort hideBox({NextPos Pos D})}
            {Send PlayerPort info(boxRemoved({NextPos Pos D}))}
            {Send Player2Port info(boxRemoved({NextPos Pos D}))}
            {Send BoardPort spawnBonus({NextPos Pos D})}
         else 
            {Send BoardPort spawnFire({NextPos Pos D})}
            {FirePropAux {NextPos Pos D} D R-1}
         end 
      end
      end
   end   

   proc{TurnByTurnAux P P2} %P = PlayerPort
   {Time.delay 500}
      local ID Action in 
         {Send P doaction(ID Action)}
         case Action
            of move(Pos) then
               {Send BoardPort movePlayer(ID Pos)}
               {Send P2 info(movePlayer(ID Pos))}
               {CheckPos Pos ID P}
            [] bomb(Pos) then
               {Send BoardPort spawnBomb(Pos)}
               {Send P2 info(bombPlanted(Pos))}
               thread {Time.delay 2000} {FireProp Pos P} end%Simulate the waiting TO DO
         end
      end 
      {TurnByTurnAux P2 P}
   end 



   %%%%%%%%%%%%%%%%%%%%%%%%           %%%%%%%%%%%%%%%%%%%%%%%%
   %---------------------------GAME---------------------------
   %%%%%%%%%%%%%%%%%%%%%%%%           %%%%%%%%%%%%%%%%%%%%%%%%



   {InitGame}
   {Time.delay 1500} %Waiting for the board to be full screened
   {TurnByTurnAux PlayerPort Player2Port}
end
