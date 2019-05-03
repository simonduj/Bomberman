functor
import
   OS
   GUI
   Input
   PlayerManager
   Browser
   Application
export
   turnByTurn:TurnByTurn
   simultaneous:Simultaneous
   treatBomb:TreatBomb
   fireProp:FireProp
   initGame:InitGame
   getValue:GetValue
define
   GetWinner
   InitGameBis
   UpdateMapBis
   BoxToRemove
   CountBoxesAux
   CountBoxes
   NewManager
   SimultaneousAux
   Rand
   Winner  
   EndOfTheGame
   GameEnd 
   BelongsTo
   HideFire
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

   fun{CountBoxes M N}
      if M == nil then N
      else
         {CountBoxes M.2 N+{CountBoxesAux M.1 0}}
      end 
   end 

   fun{CountBoxesAux L N}
      if L == nil then N
      else 
         if L.1 == 2 then 
            {CountBoxesAux L.2 N+1}
         elseif L.1 == 3 then 
            {CountBoxesAux L.2 N+1}
         else
            {CountBoxesAux L.2 N}
         end 
      end 
   end 

   fun{GetWinner Players}
      if Players.p1.score > Players.p2.score then 
         Players.p1
      else 
         Players.p2
      end 
   end
   fun{Rand Min Max}
      ({OS.rand} mod (Max - Min +1)) + Min
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

   fun{BelongsTo L P}
      if L == nil then false
      else
         if L.1 == P then true
         else
            {BelongsTo L.2 P}
         end 
      end
   end

   %Manager for the Simultaneous mode
   proc{NewManager PP1 PP2 M UpdatePosP1 GetPosP1 UpdatePosP2 GetPosP2 
      UpdateMap GetMap UpdateScoreP1 GetScoreP1 UpdateScoreP2 GetScoreP2}
      PosP1={NewCell PP1}
      PosP2={NewCell PP2}
      Map={NewCell M}
      ScoreP1={NewCell 0}
      ScoreP2={NewCell 0}
      %The lock
      PosP1Lock={NewLock}
      PosP2Lock={NewLock}
      MapLock={NewLock}
      ScoreP1Lock={NewLock}
      ScoreP2Lock={NewLock}
      %PosP1 SET/GET
   in
      proc{UpdatePosP1 P}
         lock PosP1Lock then
            PosP1:=P
         end
      end
      fun{GetPosP1}
         lock PosP1Lock then
            @PosP1
         end
      end
      %PosP2 SET/GET
      proc{UpdatePosP2 P}
         lock PosP2Lock then
            PosP2:=P
         end
      end
      fun{GetPosP2}
         lock PosP2Lock then
            @PosP2
         end
      end
      %Score GET/SET
      proc{UpdateScoreP1 P}
         lock ScoreP1Lock then 
            ScoreP1:=@ScoreP1+P
         end 
      end 
      fun{GetScoreP1}
         lock ScoreP1Lock then 
            @ScoreP1
         end 
      end 
      proc{UpdateScoreP2 P}
         lock ScoreP2Lock then 
            ScoreP2:=@ScoreP2+P
         end 
      end 
      fun{GetScoreP2}
         lock ScoreP2Lock then 
            @ScoreP2
         end 
      end 
      %Map SET/GET
      proc{UpdateMap M}
         lock MapLock then
            Map:=M
         end
      end
      fun{GetMap}
         lock MapLock then
            @Map
         end
      end
   end

   fun{UpdateMapBis Xbis X Y N}
      if X==1 then
         if Xbis.2==nil then {CopyListEx Xbis.1 Y N}|nil
         else {CopyListEx Xbis.1 Y N}|{UpdateMapBis Xbis.2 0 Y N}
         end
      else
         if Xbis.2==nil then Xbis
         else {CopyList Xbis.1}|{UpdateMapBis Xbis.2 X-1 Y N}
         end 
      end
   end
   
   fun{BoxToRemove M LOB}
      if LOB == nil then M
      else
         if {GetValue M LOB.1.y LOB.1.x} == 2 then
            {BoxToRemove {UpdateMapBis M LOB.1.y LOB.1.x 5} LOB.2}
         elseif {GetValue M LOB.1.y LOB.1.x} == 3 then
            {BoxToRemove {UpdateMapBis M LOB.1.y LOB.1.x 6} LOB.2}
         else
            {BoxToRemove M LOB.2}
         end
      end
   end
   
   fun{ExplodeBombs M Mor L}
      if M.2 == nil then {ExplodeBombsAux M.1 Mor L}
      else
         local Laux in
            Laux={ExplodeBombsAux M.1 Mor nil}
            {ExplodeBombs M.2 Mor {List.append L Laux}}
         end 
      end
   end

   fun{ExplodeBombsAux Y M L}
      if Y == nil then L
      else
         case Y.1 of bomb(pos:Pos player:P time:Time) then
            local Laux in 
               if Time == 1 then
                  Laux={FireProp M Pos P} 
               else 
                  Laux=nil
               end 
               {ExplodeBombsAux Y.2 M {List.append L Laux}}
            end 
         else
            {ExplodeBombsAux Y.2 M L}
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
   %Return the same list but replace (Y) by N
   fun{CopyListEx Ybis Y N}
      if Y==1 then
         if Ybis ==nil then nil
         else
            N|{CopyListEx Ybis.2 0 N}
         end
      else
         if Ybis == nil then nil
         else
            Ybis.1|{CopyListEx Ybis.2 Y-1 N}
         end
      end
   end
   %Return the same map but replace (X,Y) by 0
   fun{UpdateMap Xbis X Y}
      if X==1 then
         if Xbis.2==nil then {CopyListEx Xbis.1 Y 0}|nil
         else {CopyListEx Xbis.1 Y 0}|{UpdateMap Xbis.2 0 Y}
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
   fun{CheckPos M Pos ID P Score}
      %HOW TO NOT COUNT MORE THAN 1 TIME THE POINT/BONUS
      local R Mbis in
      if {GetValue M Pos.y Pos.x} == 5 then
         {Send P add(point 1 R)}
         {Send BoardPort hidePoint(Pos)}
         {Send BoardPort scoreUpdate(ID R)}
         Score=1
         Mbis={UpdateMap M Pos.y Pos.x}
         Mbis
      elseif {GetValue M Pos.y Pos.x} == 6 then 
         %DEAL WITH BONUS/BOMB
         if {BinaryRand}==0 then 
            {Send P add(bomb 1 R)}
            {Send BoardPort hideBonus(Pos)}
            Score=0
         else
            {Send P add(point 10 R)}
            {Send BoardPort hideBonus(Pos)}
            {Send BoardPort scoreUpdate(ID R)}
            Score=10
         end
         Mbis={UpdateMap M Pos.y Pos.x}
         Mbis
      else Score =0 M
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
      players(p1: player(port:PlayerPort pos:pt(x:2 y:2) life:Input.nbLives id:ID spawn:pt(x:2 y:2) score:0)
              p2: player(port:Player2Port pos:pt(x:12 y:6) life:Input.nbLives id:ID2 spawn:pt(x:12 y:6) score:0))
   end  

   fun{InitGameBis}
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


   fun{EndOfTheGame P}
      nil
   end 
   proc{HideFire L B}
      if B==true then {Send BoardPort hideBomb(L.1)}
                      {Send BoardPort hideFire(L.1)}
                      {HideFire L.2 false}
      elseif L.2 == nil then {Send BoardPort hideFire(L.1)}
      else 
         {Send BoardPort hideFire(L.1)}
         {HideFire L.2 false}
      end 
   end 

   fun{FireProp M Pos P} %LFINAL is a list containing all the Pos where fire spawned
      local R L1 L2 L3 L4 LFINAL in 
      {Send PlayerPort info(bombExploded(Pos))}
      {Send Player2Port info(bombExploded(Pos))}
      {Send BoardPort spawnFire(Pos)} %first spawnFire where the bomb was dropped
      {Send P add(bomb 1 R)}
      L1={FirePropAux M Pos 0 Input.fire}
      L2={FirePropAux M Pos 1 Input.fire}
      L3={FirePropAux M Pos 2 Input.fire}
      L4={FirePropAux M Pos 3 Input.fire}
      LFINAL={List.append Pos|nil {List.append L1 {List.append L2 {List.append L3 L4}}}}
      {Time.delay 650}
      {HideFire LFINAL true}
      LFINAL
      end 
   end 
   %Proc for propagating fire with :
   %Pos : Pos where bomb exploded
   %D : direction 
   %R : Distance for propagation ("Stop condition")
   % /!\ /!\ /!\ When we say X+1, it means one step in the north direction /!\ /!\ /!\ 
   fun{FirePropAux M Pos D R}
      local NEXT in
      if R == 0 then nil
      else
         NEXT = {GetNextValue M Pos D}
         if NEXT==1 then
            skip
            nil
            %STOP PROPAGATING
         elseif NEXT==2 then
            {Send BoardPort hideBox({NextPos Pos D})}
            {Send PlayerPort info(boxRemoved({NextPos Pos D}))}
            {Send Player2Port info(boxRemoved({NextPos Pos D}))}
            {Send BoardPort spawnPoint({NextPos Pos D})}
            {NextPos Pos D}|nil
         elseif NEXT==3 then
            {Send BoardPort hideBox({NextPos Pos D})}
            {Send PlayerPort info(boxRemoved({NextPos Pos D}))}
            {Send Player2Port info(boxRemoved({NextPos Pos D}))}
            {Send BoardPort spawnBonus({NextPos Pos D})}
            {NextPos Pos D}|nil
         else 
            {Send BoardPort spawnFire({NextPos Pos D})}
            {NextPos Pos D}|{FirePropAux M {NextPos Pos D} D R-1}
         end 
      end
      end
   end   

   fun{TurnByTurnAux2 P P2 ID Action PosP M}
      {Send P doaction(ID Action)}
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

            bomb(pos:Pos player:P time:Input.fire+1)
         else 
         nil
      end
   end 

   proc{TurnByTurnAux Players M} %N=number of boxes currently left
      {Time.delay 350} %Just to see the dynamic !!
      local Mbis PosP PosP2  NewLife NewLife2 End Winner ScoreP1 ScoreP2 in
         local Action Action2 Maux B1 B2 IsT IsT2 W1 W2 LOB Mup in
                    
            LOB={ExplodeBombs M M nil}
            IsT={BelongsTo LOB Players.p1.pos}
            IsT2={BelongsTo LOB Players.p2.pos}
            Mup={BoxToRemove M LOB}
            %IF THERE ARE NO BOXES LEFT => END OF THE GAME
         if {CountBoxes Mup 0} < 1 then 
            %Winner={GetWinner}
            End=true
            Winner={GetWinner Players}
         else

            
            %We hide the touched Players at the same time
            if IsT == true then
               local A B in 
                  {Send Players.p1.port gotHit(A B)}
               end 
               NewLife = Players.p1.life-1
               {Send BoardPort hidePlayer(Players.p1.id)}
               {Send BoardPort lifeUpdate(Players.p1.id NewLife)}
            else 
               NewLife = Players.p1.life  
            end
            if IsT2 == true then
               local A B in 
                  {Send Players.p2.port gotHit(A B)}
               end 
               NewLife2 = Players.p2.life-1
               {Send BoardPort hidePlayer(Players.p2.id)}
               {Send BoardPort lifeUpdate(Players.p2.id NewLife2)}
            else 
               NewLife2 = Players.p2.life
            
            end 

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%% END CHEKING HERE %%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if NewLife == 0 then 
               End=true
               Winner={GetWinner Players}
            elseif NewLife2 == 0 then 
               End=true 
               Winner={GetWinner Players}
            else 
               End = false 
            end 

            if End == false then 

            %MAYBE WE WILL HAVE TO CHANGE THE ORDER FOR THE LOGIC OF THE VIEW 
            if IsT == true then 
               B1=nil
               Maux=Mup
               local IDx Posx in 
                  {Send Players.p1.port spawn(IDx Posx)}
                  {Send BoardPort spawnPlayer(IDx Posx)}
                  PosP = Posx
               end 
               ScoreP1=0
               %Do What hase to be done
            else
               local IDx Actionx in
                  B1={TurnByTurnAux2 Players.p1.port Players.p2.port IDx Actionx PosP M}
                  W1={AddBomb B1 Mup}
                  Maux={CheckPos W1 PosP Players.p1.id Players.p1.port ScoreP1}
               end 
            end 
            {Time.delay 350}
            if IsT2 == true then
               B2=nil
               Mbis=Maux
               local IDx Posx in 
                  {Send Players.p2.port spawn(IDx Posx)}
                  {Send BoardPort spawnPlayer(IDx Posx)}
                  PosP2 = Posx
               end 
               ScoreP2=0
               %Do What has to be done
            else     
               local IDx Actionx  in 
                  B2={TurnByTurnAux2 Players.p2.port Players.p1.port IDx Actionx PosP2 Maux}
                  W2={AddBomb B2 Maux}
                  Mbis={CheckPos W2 PosP2 Players.p2.id Players.p2.port ScoreP2}
               end 
            end 

            end %CLOSE the "if End == false then ... END"
         end 

         end

         if End == false then 
         {TurnByTurnAux 
            players(p1:player(port:Players.p1.port 
                        pos:PosP 
                        life:NewLife 
                        id:Players.p1.id 
                        spawn:Players.p1.spawn
                        score:Players.p1.score + ScoreP1)

                    p2:player(port:Players.p2.port 
                        pos:PosP2 
                        life:NewLife2 
                        id:Players.p2.id 
                        spawn:Players.p2.spawn
                        score:Players.p2.score + ScoreP2))

            {DecrBombs Mbis}}%We permute P2 and P in the recursive call to have the TurnByTurn
         else 
            %DISPLAY THE WINNER
            {Send BoardPort displayWinner(Winner.id)}
         end%Close the second END contidion 
      end
   end

   proc{Simultaneous Players M}

      local Winner UpdatePosP1 GetPosP1 UpdatePosP2 GetPosP2 UpdateMap GetMap
      UpdateScoreP1 GetScoreP1 UpdateScoreP2 GetScoreP2

      proc{SimultaneousAux P M N Winner} %N just tell wich player is running this proc
         {Time.delay {Rand Input.thinkMin Input.thinkMax}}
         local B W IDx Actionx PosP Paux Score in 
         B={TurnByTurnAux2 P.port P.port IDx Actionx PosP M} 
         if B == nil then 
               Paux=player(port:P.port pos:PosP life:P.life id:P.id spawn:P.spawn)
               if N==1 then 
                  {UpdatePosP1 PosP}
                  %CHECK POS AND UPDATEMAP
                  local Maux in 
                     Maux={CheckPos {GetMap} PosP P.id P.port Score}
                     {UpdateScoreP1 Score}
                     {UpdateMap Maux}
                  end 
               else
                  {UpdatePosP2 PosP}
                  %CHECK POS AND UPDATEMAP
                  local Maux in 
                     Maux={CheckPos {GetMap} PosP P.id P.port Score}
                     {UpdateMap Maux}
                     {UpdateScoreP2 Score}
                  end 
               end  
            {SimultaneousAux Paux {GetMap} N Winner}
         else 
            Paux = P
            thread 
               local L in 
                  {Time.delay {Rand Input.timingBombMin Input.timingBombMax}}
                  %HANDLE BOMB EXPLODING 
                  L={FireProp {GetMap} B.pos P.port}
                  {UpdateMap {BoxToRemove M L}}
                  if {CountBoxes {GetMap} 0} < 1 then 
                     Winner=unit
                     {Application.exit 0}
                  end 
                  if {BelongsTo L {GetPosP1}} then 
                     local A B in 
                        {Send Players.p1.port gotHit(A B)}
                        case B of death(NewLife) then 
                           {Send BoardPort lifeUpdate(Players.p1.id NewLife)}
                           if NewLife == 0 then 
                              {Send BoardPort displayWinner(P.id)}
                              {Time.delay 1000}
                              Winner=unit
                              {Application.exit 0}
                           end 
                        end 
                     end 
                     {Send BoardPort hidePlayer(Players.p1.id)}
                     local IDx Posx in
                        {Send Players.p1.port spawn(IDx Posx)}
                        {Send BoardPort spawnPlayer(IDx Posx)}
                     end
                     %LIFE UPDATE EVERYWHEEEEERE
                  end
                  if {BelongsTo L {GetPosP2}} then 
                     local A B in 
                        {Send Players.p2.port gotHit(A B)}
                        case B of death(NewLife) then
                           {Send BoardPort lifeUpdate(Players.p2.id NewLife)}
                           if NewLife == 0 then 
                              {Send BoardPort displayWinner(P.id)}
                              {Time.delay 1000}
                              Winner=unit
                              {Application.exit 0}
                           end 
                        end 
                     end
                     {Send BoardPort hidePlayer(Players.p2.id)}
                     local IDx Posx in 
                        {Send Players.p2.port spawn(IDx Posx)}
                        {Send BoardPort spawnPlayer(IDx Posx)}
                     end 
                     %LIFE UPDATE EVERYWHEEEEERE
                  end 
               end
            end 
            {SimultaneousAux Paux M N Winner}
         end 
         end 
      end 

      in 

      {NewManager Players.p1.spawn Players.p2.spawn M
         UpdatePosP1 GetPosP1
         UpdatePosP2 GetPosP2
         UpdateMap GetMap
         UpdateScoreP1 GetScoreP1 
         UpdateScoreP2 GetScoreP2
      }

      thread 
         {SimultaneousAux Players.p1 M 1 Winner}
      end 

      thread 
         {SimultaneousAux Players.p2 M 2 Winner}
      end

      {Wait Winner}
      end 
   end 



   %%%%%%%%%%%%%%%%%%%%%%%%           %%%%%%%%%%%%%%%%%%%%%%%%
   %---------------------------GAME---------------------------
   %%%%%%%%%%%%%%%%%%%%%%%%           %%%%%%%%%%%%%%%%%%%%%%%%



   {Time.delay 1500} %Waiting for the board to be full screened
   if Input.isTurnByTurn == true then 
      PlayersDat={InitGame}
      {TurnByTurnAux PlayersDat Input.map}
   else
      PlayersDat={InitGameBis}
      {Simultaneous PlayersDat Input.map}
   end 
end
