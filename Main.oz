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
   IsIn
   IsTouchedAux
   IsTouched
   ExplodeBombs
   ExplodeBombsAux
   DecrBombs
   DecrBomb
   DecrBombsList
   AddBomb
   AddBombList
   AddBombAux
   PlayersDat
   CopyList
   CopyListEx
   UpdateMap
   TurnByTurnAux2
   TurnByTurnAux
   IsTouchedBis
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

   fun{IsIn PosB Pos D R}%D=N/S/E/W
      if R == 0 then false
      elseif {NextPos PosB D} == Pos then true
      else {IsIn {NextPos PosB D} Pos D R-1} end 
   end

   fun{IsTouchedBis PosB Pos}
      if PosB == Pos then true 
      elseif {IsIn PosB Pos 0 3} == true then true
      elseif {IsIn PosB Pos 1 3} == true then true 
      elseif {IsIn PosB Pos 2 3} == true then true
      elseif {IsIn PosB Pos 3 3} == true then true 
      else false end 
   end

   fun{IsTouchedAux Y Pos}
      if Y == nil then false
      else
         case Y.1 of bomb(p:P pos:PosB time:Time) then
            if Time == 1 then
               if {IsTouchedBis Pos PosB} == true then true
               else
                  {IsTouchedAux Y.2 Pos}
               end
            else
               {IsTouchedAux Y.2 Pos}
            end 
         else
            {IsTouchedAux Y.2 Pos}
         end
      end
   end

   fun{IsTouched M Pos}
      if M == nil then false
      else
         if {IsTouchedAux M.1 Pos} == true then true %return true
         else
            {IsTouched M.2 Pos}
         end
      end
   end
   
   proc{ExplodeBombs M Mor}
      if M.2 == nil then {ExplodeBombsAux M.1 Mor}
      else
         {ExplodeBombsAux M.1 Mor}
         {ExplodeBombs M.2 Mor}
      end
   end

   proc{ExplodeBombsAux Y M}
      if Y == nil then skip
      else
         case Y.1 of bomb(pos:Pos player:P time:Time) then
            if Time == 1 then {FireProp M Pos P} end 
            {ExplodeBombsAux Y.2 M}
         else
            {ExplodeBombsAux Y.2 M}
         
         end
      end    
   end

   fun{AddBombList L Y B}
      if Y==1 then
         if L==nil then nil
         else
            B|{AddBombList L.2 0 B}
         end
      else
         if L==nil then nil
         else
            L.1|{AddBombList L.2 Y-1 B}
         end
      end    
   end


   fun{AddBomb B M}
      if B==nil then M
      else
         {AddBombAux B M B.pos.y B.pos.x}
      end
   end

   fun{AddBombAux B M X Y}
      if X==1 then
         if M.2==nil then {AddBombList M.1 Y B}|nil
         else {AddBombList M.1 Y B}|{AddBombAux B M.2 0 Y}
         end
      else
         if M.2==nil then M
         else {CopyList M.1}|{AddBombAux B M.2 X-1 Y}
         end
      end
   end

   fun{DecrBombs M}
      if M.2==nil then {DecrBombsList M.1}|nil
      else
         {DecrBombsList M.1}|{DecrBombs M.2}
      end
   end

   fun{DecrBombsList L}
      if L==nil then nil
      else
         case L.1 of bomb(pos:Pos player:Player time:Time) then
            {DecrBomb L.1}|{DecrBombsList L.2}
         else
            L.1|{DecrBombsList L.2}
         end
      end   
   end

   fun{DecrBomb B}
      if B.time == 1 then 0
      else
         bomb(pos:B.pos player:B.player time:B.time-1)
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
         Mbis={UpdateMap M Pos.y Pos.x}
         Mbis
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
         Mbis={UpdateMap M Pos.y Pos.x}
         Mbis
      else M
      end 
      end
   end 
   fun{InitGame}
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
      %return a record with all infos about players 
      players(p1: player(port:PlayerPort pos:pt(x:2 y:2) life:Input.nbLives id:ID spawn:pt(x:2 y:2))
              p2: player(port:Player2Port pos:pt(x:12 y:6) life:Input.nbLives id:ID2 spawn:pt(x:12 y:6)))
   end  
   proc{FireProp M Pos P}
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
         {Browser.browse Pos}
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

   fun{TurnByTurnAux2 P P2 ID Action PosP M}
      {Send P doaction(ID Action)} %Ask the Player to do his action (P(bomb)=0.1 & P(move)=0.9)
      case Action
         of move(Pos) then
            {Send BoardPort movePlayer(ID Pos)}
            {Send P2 info(movePlayer(ID Pos))}

            {Send P info(movePlayer(ID Pos))}
            PosP=Pos

            nil
         [] bomb(Pos) then
            {Send BoardPort spawnBomb(Pos)}
            {Send P2 info(bombPlanted(Pos))}
            {Send P info(bombPlanted(Pos))}
            PosP=Pos

            bomb(pos:Pos player:P time:Input.fire)
      end
   end 

   proc{TurnByTurnAux Players M} %P = PlayerPort 
      {Time.delay 500} %Just to see the dynamic !!
      local Mbis PosP PosP2  NewLife NewLife2 in
         local Action Action2 Maux B1 B2 IsT IsT2 W1 W2 in
                    
                      
            {ExplodeBombs M M}

            IsT={IsTouched M Players.p1.pos}
            IsT2={IsTouched M Players.p2.pos}

            %We hide the touched Players at the same time
            if IsT == true then
               NewLife = Players.p1.life-1
               {Send BoardPort hidePlayer(Players.p1.id)}
               {Send BoardPort lifeUpdate(Players.p1.id NewLife)}
            else 
               NewLife = Players.p1.life  
            end
            if IsT2 == true then
               NewLife = Players.p2.life-1
               {Send BoardPort hidePlayer(Players.p2.id)}
               {Send BoardPort lifeUpdate(Players.p2.id NewLife2)}
            else 
               NewLife2 = Players.p2.life
            
            end 

            {Time.delay 500}
            %MAYBE WE WILL HAVE TO CHANGE THE ORDER FOR THE LOGIC OF THE VIEW 
            if IsT == true then 
               B1=nil
               Maux=M
               PosP=Players.p1.spawn
               {Send BoardPort spawnPlayer(Players.p1.spawn)}
               %Do What hase to be done
            else
               B1={TurnByTurnAux2 Players.p1.port Players.p2.port Players.p1.id Action PosP M}
               W1={AddBomb B1 M}
               Maux={CheckPos W1 PosP Players.p1.id Players.p1.port}
            end 
            {Time.delay 500}                               
            if IsT2 == true then
               B2=nil
               Mbis=Maux
               PosP2=Players.p2.spawn
               {Send BoardPort spawnPlayer(Players.p2.spawn)}
               %Do What has to be done
            else       
               B2={TurnByTurnAux2 Players.p2.port Players.p1.port Players.p2.id Action2 PosP2 Maux}
               W2={AddBomb B2 Maux}

               Mbis={CheckPos W2 PosP2 Players.p2.id Players.p2.port}
                                          
            end 

         end 
         {TurnByTurnAux 
            players(p1:player(port:Players.p1.port 
                        pos:PosP 
                        life:NewLife 
                        id:Players.p1.id 
                        spawn:Players.p1.spawn)

                    p2:player(port:Players.p2.port 
                        pos:PosP2 
                        life:NewLife2 
                        id:Players.p2.id 
                        spawn:Players.p2.spawn))

            {DecrBombs Mbis}}%We permute P2 and P in the recursive call to have the TurnByTurn
      end
   end



   %%%%%%%%%%%%%%%%%%%%%%%%           %%%%%%%%%%%%%%%%%%%%%%%%
   %---------------------------GAME---------------------------
   %%%%%%%%%%%%%%%%%%%%%%%%           %%%%%%%%%%%%%%%%%%%%%%%%



   PlayersDat={InitGame}
   {Time.delay 1500} %Waiting for the board to be full screened
   {TurnByTurnAux PlayersDat Input.map }
end
