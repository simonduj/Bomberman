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
   CopyList
   CopyListEx
   UpdateMap
   TurnByTurnAux2
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
  fun{CopyList Ybis}
      if Ybis == nil then nil
      else Ybis.1|{CopyList Ybis.2}
      end   
   end
   %Return the same list but replace (Y) by 0
   fun{CopyListEx Ybis Y}
      if Y==1 then
         if Ybis ==nil then nil
         else
            0|{CopyListEx Ybis.2 0}
         end
      else
         if Ybis == nil then nil
         else
            Ybis.1|{CopyListEx Ybis.2 Y-1}
         end
      end
   end
   %Return the same map but replace (X,Y) by 0
   fun{UpdateMap Xbis X Y}
      if X==1 then
         if Xbis.2==nil then {CopyListEx Xbis.1 Y}|nil
         else {CopyListEx Xbis.1 Y}|{UpdateMap Xbis.2 0 Y}
         end
      else
         if Xbis.2==nil then Xbis
         else {CopyList Xbis.1}|{UpdateMap Xbis.2 X-1 Y}
         end 
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
   fun{GetNextValue M Pos D}
      if D==0 then {GetValue M Pos.y+1 Pos.x}
      elseif D==1 then {GetValue M Pos.y Pos.x+1}
      elseif D==2 then {GetValue M Pos.y-1 Pos.x}
      else {GetValue M Pos.y Pos.x-1}
      end 
   end 
   %Return the same map as M but with M[Pos]=0
   %Return the Next Position based on the direction D: N/E/S/O
   fun{NextPos Pos D}
      if D==0 then pt(x:Pos.x y:Pos.y+1)
      elseif D==1 then pt(x:Pos.x+1 y:Pos.y)
      elseif D==2 then pt(x:Pos.x y:Pos.y-1)
      else pt(x:Pos.x-1 y:Pos.y)
      end 
   end 
   fun{CheckPos M Pos ID P}
      %HOW TO NOT COUNT MORE THAN 1 TIME THE POINT/BONUS
      local R Mbis in
      if {GetValue M Pos.y Pos.x} == 2 then
         {Send P add(point 1 R)}
         {Send BoardPort hidePoint(Pos)}
         {Send BoardPort scoreUpdate(ID R)}
      elseif {GetValue M Pos.y Pos.x} == 3 then 
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
      Mbis={UpdateMap M Pos.y Pos.x}
      Mbis
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
   proc{FireProp M Pos PosP2 P P2}
      local R in 
      {Send PlayerPort info(bombExploded(Pos))}
      {Send Player2Port info(bombExploded(Pos))}
      {Send BoardPort spawnFire(Pos)} %first spawnFire where the bomb was dropped
      {Send P add(bomb 1 R)}
      {FirePropAux M Pos 0 Input.fire}
      {FirePropAux M Pos 1 Input.fire}
      {FirePropAux M Pos 2 Input.fire}
      {FirePropAux M Pos 3 Input.fire}
      end 
   end 
   %Proc for propagating fire with :
   %Pos : Pos where bomb exploded
   %D : direction 
   %R : Distance for propagation ("Stop condition")
   % /!\ /!\ /!\ When we say X+1, it means one step in the north direction /!\ /!\ /!\ 
   proc{FirePropAux M Pos D R}
      local NEXT in
      if R == 0 then skip 
      else
         NEXT = {GetNextValue M Pos D}
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
            {FirePropAux M {NextPos Pos D} D R-1}
         end 
      end
      end
   end   

   proc{TurnByTurnAux2 P P2 ID Action PosP PosP2 M}
      {Send P doaction(ID Action)} %Ask the Player to do his action (P(bomb)=0.1 & P(move)=0.9)
      case Action
         of move(Pos) then
            {Send BoardPort movePlayer(ID Pos)}
            {Send P2 info(movePlayer(ID Pos))}
            {Send P info(movePlayer(ID Pos))}
            PosP=Pos
         [] bomb(Pos) then
            {Send BoardPort spawnBomb(Pos)}
            {Send P2 info(bombPlanted(Pos))}
            {Send P info(bombPlanted(Pos))}
            PosP=Pos
            thread 
            {Time.delay 2000} {FireProp M PosP PosP2 P P2} end%Simulate the waiting TO DO
      end
   end 

   proc{TurnByTurnAux P P2 M} %P = PlayerPort 
      {Time.delay 500} %Just to see the dynamic !!
      local Mbis in
         local PosP PosP2 ID Action ID2 Action2 Maux in
            {TurnByTurnAux2 P P2 ID Action PosP PosP2 M}
            Maux={CheckPos M PosP ID P}
            {Time.delay 500}
            {TurnByTurnAux2 P2 P ID2 Action2 PosP2 PosP Maux}
            Mbis={CheckPos Maux PosP2 ID2 P2}
         end 
         {TurnByTurnAux P P2 Mbis}%We permute P2 and P in the recursive call to have the TurnByTurn
      end
   end



   %%%%%%%%%%%%%%%%%%%%%%%%           %%%%%%%%%%%%%%%%%%%%%%%%
   %---------------------------GAME---------------------------
   %%%%%%%%%%%%%%%%%%%%%%%%           %%%%%%%%%%%%%%%%%%%%%%%%



   {InitGame}
   {Time.delay 1500} %Waiting for the board to be full screened
   {TurnByTurnAux PlayerPort Player2Port Input.map}
end
