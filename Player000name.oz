functor
import
   Input
   Browser
   Projet2019util
   Int
   List
   OS
export
   portPlayer:StartPlayer
define   
   StartPlayer
   TreatStream
   Name = 'namefordebug'
   GetState
   GetID
   AssignSpawn
   IsOff
   DoAction
   Add
   GotHit
   Info
   RemoveBombFromList
   ListMap
   Spawn
   UpdateMap
   Random
   NextPos
   CheckCanMove
   GetValue
   RandomMove
   RandomNewPos
   DoMove
   ReadMap
   Binary

in
   fun{NextPos Pos D}
      if D==0 then pt(x:Pos.x y:Pos.y+1)
      elseif D==1 then pt(x:Pos.x+1 y:Pos.y)
      elseif D==2 then pt(x:Pos.x y:Pos.y-1)
      else pt(x:Pos.x-1 y:Pos.y)
      end 
   end 

   /*
   Pre : Prend la map stockee dans le fichier input
   Post : Retourne une liste de points avec la valeur passee en argument
   */

   fun {ListMap Arg}
      fun {ReadMap Row Column}
         if (Row > (Input.nbRow)) then nil
         else
            if(Column == Input.nbColumn) then 
               if({List.nth {List.nth Input.map Row} Column} == Arg) then
                  pt(x:Column y:Row)|{ReadMap Row+1 1}
               else
                  {ReadMap Row+1 1}
               end
            else 
               if({List.nth {List.nth Input.map Row} Column} == Arg) then
                  pt(x:Column y:Row)|{ReadMap Row Column+1}
               else
                  {ReadMap Row Column+1}
               end
            end
         end
      end
      {ReadMap 1 1}
   end

   fun{GetValue L Pos}
      {Nth {Nth L Pos.x} Pos.y}
   end 


   /*
   @Pre: Prend une position en argument
   @Post: Retourne true si la position passee en argument est valide pour un deplacement
   */
   fun{CheckCanMove Pos}
      local Map in
         Map = Input.map
         if {Or {GetValue Map Pos}==0 {GetValue Map Pos}==4} then true
         else false 
         end
      end
   end

   fun{Random}
      local A in
         A = {OS.rand}
         if (A mod 2 == 0) then
            A mod 2
         else
            A mod 2 + 2
         end
      end
   end

   fun{Binary}
      local N in 
            N={OS.rand}
            if N mod 2 == 0 then 0
            else 1
            end 
      end 
   end
   /*
   @Pre: Prend une position de depart en argument
   @Post: Retourne une nouvelle position aleatoire valide pour un deplacement
   */
   fun{RandomMove Start}
      local Ret in
         Ret = {NextPos Start {Random}}
         if ({CheckCanMove Ret}==true) then Ret
         else {RandomMove Start}
         end
      end
   end

   /*
   @Pre: Prend une liste et une position en argument
   @Post: Retourne la liste en ayant enleve la position passee en argument
   */

   fun {RemoveBombFromList L Pos}
    case L of nil then nil
    []H|T then
       if {And H.x==Pos.x H.y==Pos.y} == true then
          {RemoveBombFromList T Pos}
       else
          H|{RemoveBombFromList T Pos}
       end
    end
   end
   
   /*
   @Pre: Prend un joueur en argument
   @Post: Retourne true si le joueur est hors du jeu et false sinon
   */

   fun {IsOff State}
      if {Or State.spawned==true State.lives<1} then
         true
      else
         false 
      end
   end

   /*
   @Pre: ID passee en argument n'est pas liee
   @Post: Retourne le meme etat et lie la variable ID a sa valeur dans State
   */
   
   fun {GetID State ID}
      ID = State.id
      State
   end

   /*
   @Pre: ID et Resp passees en argument n'est pas liee
   @Post: Retourne le meme etat et lie la variable ID a sa valeur dans State et Resp a spawned de State
   */

   fun {GetState State ID Resp}
      ID = State.id
      Resp = State.spawned
      State
   end

   /*
   @Pre: Prend une position en argument
   @Post: Retourne un etat dans lequel la position de spawn a ete mise a jour
   */

   fun {AssignSpawn Pos State}
      state(id:State.id spawned:State.spawned dead:State.dead spawnpos:Pos pos:State.pos point:State.point lives:State.lives livesOtherPlayer:State.livesOtherPlayer nbBombPlaced:State.nbBombPlaced nbBombLeft:State.nbBombLeft shield:State.shield otherPlayerDead:State.otherPlayerDead stateotherplayer:State.stateotherplayer bombsOnTerrain:State.bombsOnTerrain posOtherPlayer:State.posOtherPlayer otherPlayerSpawnPos:State.otherPlayerSpawnPos)
   end

   /*
   @Pre: ID et Pos passees en argument ne sont pas liees
   @Post: Retourne le meme etat lie la position a spawnpos et attribue les valeurs correctes a Pos et ID
   */

   fun {Spawn State ID Pos}
   local NewState in
      if {Or State.spawned==true State.lives<1} then
         ID = null
         Pos = null
      else
         ID = State.id
         Pos = State.spawnpos
         NewState = state(id:State.id spawned:true dead:false spawnpos:State.spawnpos pos:Pos point:State.point lives:State.lives livesOtherPlayer:State.livesOtherPlayer nbBombPlaced:State.nbBombPlaced nbBombLeft:State.nbBombLeft shield:State.shield otherPlayerDead:State.otherPlayerDead stateotherplayer:State.stateotherplayer bombsOnTerrain:State.bombsOnTerrain posOtherPlayer:State.posOtherPlayer otherPlayerSpawnPos:State.otherPlayerSpawnPos)
         NewState
      end
   end
   end

   /*
   @Pre: ID et Action passees en argument ne sont pas liees
   @Post: Retourne le meme etat et lie la variable ID a sa valeur dans State et Action a la valeur que le joueur va effectuer (determinee de maniere aleatoire)
   */

   fun {DoAction State ID Action}
   local A NewState Pos in
      Pos = {RandomMove State.pos}
      if {IsOff State} then
         ID = null
         Action = null
      else
         A = {Binary}
         if A == 0 then
            NewState = {DoMove State Pos}
            ID = State.id
            Action = move(Pos)
         else 
            if State.nbBombLeft > 0 then
                  ID = State.id
                  NewState = state(id:State.id spawned:State.spawned dead:State.dead spawnpos:State.spawnpos pos:State.pos point:State.point lives:State.lives livesOtherPlayer:State.livesOtherPlayer nbBombPlaced:State.nbBombPlaced+1 nbBombLeft:State.nbBombLeft-1 shield:State.shield otherPlayerDead:State.otherPlayerDead stateotherplayer:State.stateotherplayer bombsOnTerrain:State.bombsOnTerrain posOtherPlayer:State.posOtherPlayer otherPlayerSpawnPos:State.otherPlayerSpawnPos)
                  Action = bomb(State.pos)
            else
               ID = State.id
               Action = move(Pos)
            end
         end
      end 
      NewState
   end
   end

   fun{DoMove State Pos}
   local NewState in
      NewState = state(id:State.id spawned:State.spawned dead:State.dead spawnpos:State.spawnpos pos:Pos point:State.point lives:State.lives livesOtherPlayer:State.livesOtherPlayer nbBombPlaced:State.nbBombPlaced nbBombLeft:State.nbBombLeft shield:State.shield otherPlayerDead:State.otherPlayerDead stateotherplayer:State.stateotherplayer bombsOnTerrain:State.bombsOnTerrain posOtherPlayer:State.posOtherPlayer otherPlayerSpawnPos:State.otherPlayerSpawnPos)
      NewState
   end
   end

   fun {Add State Type Option Result}
   local NewState in
      case Type of bomb then
         if {Int.isNat Option} == true then
            NewState = state(id:State.id spawned:State.spawned dead:State.dead spawnpos:State.spawnpos pos:State.pos point:State.point lives:State.lives livesOtherPlayer:State.livesOtherPlayer nbBombPlaced:State.nbBombPlaced nbBombLeft:State.nbBombLeft+Option shield:State.shield otherPlayerDead:State.otherPlayerDead stateotherplayer:State.stateotherplayer bombsOnTerrain:State.bombsOnTerrain posOtherPlayer:State.posOtherPlayer otherPlayerSpawnPos:State.otherPlayerSpawnPos)
            Result = NewState.nbBombLeft
         else
            Result = null
            raise unknownOption('Option not recognized by the Player '#Option) end
         end
      []point then
         if {Int.isNat Option} == true then
            NewState = state(id:State.id spawned:State.spawned dead:State.dead spawnpos:State.spawnpos pos:State.pos point:State.point+Option lives:State.lives livesOtherPlayer:State.livesOtherPlayer nbBombPlaced:State.nbBombPlaced nbBombLeft:State.nbBombLeft shield:State.shield otherPlayerDead:State.otherPlayerDead stateotherplayer:State.stateotherplayer bombsOnTerrain:State.bombsOnTerrain posOtherPlayer:State.posOtherPlayer otherPlayerSpawnPos:State.otherPlayerSpawnPos)
            Result = NewState.point
         else
            Result = null
            raise unknownOption('Option not recognized by the Player '#Option) end
         end
      []shield then
         if {Int.isNat Option} == true then
            NewState = state(id:State.id spawned:State.spawned dead:State.dead spawnpos:State.spawnpos pos:State.pos point:State.point lives:State.lives livesOtherPlayer:State.livesOtherPlayer nbBombPlaced:State.nbBombPlaced nbBombLeft:State.nbBombLeft shield:State.shield+Option otherPlayerDead:State.otherPlayerDead stateotherplayer:State.stateotherplayer bombsOnTerrain:State.bombsOnTerrain posOtherPlayer:State.posOtherPlayer otherPlayerSpawnPos:State.otherPlayerSpawnPos)
            Result = NewState.shield
         else
            Result = null
            raise unknownOption('Option not recognized by the Player '#Option) end
         end
      []life then
         if {Int.isNat Option} == true then
            NewState = state(id:State.id spawned:State.spawned dead:State.dead spawnpos:State.spawnpos pos:State.pos point:State.point lives:State.lives+Option livesOtherPlayer:State.livesOtherPlayer nbBombPlaced:State.nbBombPlaced nbBombLeft:State.nbBombLeft shield:State.shield otherPlayerDead:State.otherPlayerDead stateotherplayer:State.stateotherplayer bombsOnTerrain:State.bombsOnTerrain posOtherPlayer:State.posOtherPlayer otherPlayerSpawnPos:State.otherPlayerSpawnPos)
            Result = NewState.lives
         else
            Result = nil
            raise unknownOption('Option not recognized by the Player '#Option) end
         end
      else
         raise unknownAdd('Add not recognised by the Player '#Type) end
      end
      NewState
   end
   end

   /*
   @Pre: ID et Result passees en argument ne sont pas liees
   @Post: Retourne le meme etat et lie la variable ID a sa valeur dans State et Result a death(State.lives)
   */

   fun {GotHit State ID Result}
   local NewState in
      if {IsOff State} == true then
         ID = null
         Result = null
      else
         ID = State.id
         NewState = state(id:State.id spawned:false dead:State.dead spawnpos:State.spawnpos pos:State.pos point:State.point lives:State.lives-1 livesOtherPlayer:State.livesOtherPlayer nbBombPlaced:State.nbBombPlaced nbBombLeft:State.nbBombLeft shield:State.shield otherPlayerDead:State.otherPlayerDead stateotherplayer:State.stateotherplayer bombsOnTerrain:State.bombsOnTerrain posOtherPlayer:State.posOtherPlayer otherPlayerSpawnPos:State.otherPlayerSpawnPos)
         Result = death(State.lives)
      end
      NewState 
   end
   end

   /*
   @Pre: Prend en argument un message
   @Post: Le message est decode et l'etat est mis a jour accordement a celui ci
   */

   fun {Info State Message}
      local NewState in
         case Message 
         of spawnPlayer(ID Pos) then
            if ID == State.id then
               NewState = state(id:State.id spawned:true dead:true spawnpos:Pos pos:State.pos point:State.point lives:State.lives livesOtherPlayer:State.livesOtherPlayer nbBombPlaced:State.nbBombPlaced nbBombLeft:State.nbBombLeft shield:State.shield otherPlayerDead:State.otherPlayerDead stateotherplayer:State.stateotherplayer bombsOnTerrain:State.bombsOnTerrain posOtherPlayer:State.posOtherPlayer otherPlayerSpawnPos:State.otherPlayerSpawnPos)
            else
               NewState = state(id:State.id spawned:State.spawned dead:State.dead spawnpos:State.spawnpos pos:State.pos point:State.point lives:State.lives livesOtherPlayer:State.livesOtherPlayer nbBombPlaced:State.nbBombPlaced nbBombLeft:State.nbBombLeft shield:State.shield otherPlayerDead:false stateotherplayer:true bombsOnTerrain:State.bombsOnTerrain posOtherPlayer:Pos otherPlayerSpawnPos:Pos)
            end
         []movePlayer(ID Pos) then
            if ID == State.id then
               NewState = state(id:State.id spawned:State.spawned dead:State.dead spawnpos:State.spawnpos pos:Pos point:State.point lives:State.lives livesOtherPlayer:State.livesOtherPlayer nbBombPlaced:State.nbBombPlaced nbBombLeft:State.nbBombLeft shield:State.shield otherPlayerDead:State.otherPlayerDead stateotherplayer:State.stateotherplayer bombsOnTerrain:State.bombsOnTerrain posOtherPlayer:State.posOtherPlayer otherPlayerSpawnPos:State.otherPlayerSpawnPos)
            else NewState = state(id:State.id spawned:State.spawned dead:State.dead spawnpos:State.spawnpos pos:State.pos point:State.point lives:State.lives livesOtherPlayer:State.livesOtherPlayer nbBombPlaced:State.nbBombPlaced nbBombLeft:State.nbBombLeft shield:State.shield otherPlayerDead:State.otherPlayerDead stateotherplayer:State.stateotherplayer bombsOnTerrain:State.bombsOnTerrain posOtherPlayer:Pos otherPlayerSpawnPos:State.otherPlayerSpawnPos)
            end
         []deadPlayer(ID) then
            if State.id == ID then
               if State.lives == 1 then
                  NewState = state(id:State.id spawned:false dead:true spawnpos:State.spawnpos pos:State.pos point:State.point lives:State.lives-1 livesOtherPlayer:State.livesOtherPlayer nbBombPlaced:State.nbBombPlaced nbBombLeft:State.nbBombLeft shield:State.shield otherPlayerDead:State.otherPlayerDead stateotherplayer:State.stateotherplayer bombsOnTerrain:State.bombsOnTerrain posOtherPlayer:State.posOtherPlayer otherPlayerSpawnPos:State.otherPlayerSpawnPos)
               else
                  NewState = state(id:State.id spawned:State.spawned dead:State.dead spawnpos:State.spawnpos pos:State.pos point:State.point lives:State.lives-1 livesOtherPlayer:State.livesOtherPlayer nbBombPlaced:State.nbBombPlaced nbBombLeft:State.nbBombLeft shield:State.shield otherPlayerDead:State.otherPlayerDead stateotherplayer:State.stateotherplayer bombsOnTerrain:State.bombsOnTerrain posOtherPlayer:State.posOtherPlayer otherPlayerSpawnPos:State.otherPlayerSpawnPos)
               end
            else
               State.stateotherplayer = false
               if State.livesOtherPlayer == 1 then
                  NewState = state(id:State.id spawned:State.spawned dead:State.dead spawnpos:State.spawnpos pos:State.pos point:State.point lives:State.lives livesOtherPlayer:State.livesOtherPlayer-1 nbBombPlaced:State.nbBombPlaced nbBombLeft:State.nbBombLeft shield:State.shield otherPlayerDead:true stateotherplayer:false bombsOnTerrain:State.bombsOnTerrain posOtherPlayer:State.posOtherPlayer otherPlayerSpawnPos:State.otherPlayerSpawnPos)
               else
                  NewState = state(id:State.id spawned:State.spawned dead:State.dead spawnpos:State.spawnpos pos:State.pos point:State.point lives:State.lives livesOtherPlayer:State.livesOtherPlayer-1 nbBombPlaced:State.nbBombPlaced nbBombLeft:State.nbBombLeft shield:State.shield otherPlayerDead:State.otherPlayerDead stateotherplayer:State.stateotherplayer bombsOnTerrain:State.bombsOnTerrain posOtherPlayer:State.posOtherPlayer otherPlayerSpawnPos:State.otherPlayerSpawnPos)
               end
            end
         []bombPlanted(Pos) then
            NewState = state(id:State.id spawned:State.spawned dead:State.dead spawnpos:State.spawnpos pos:State.pos point:State.point lives:State.lives livesOtherPlayer:State.livesOtherPlayer nbBombPlaced:State.nbBombPlaced+1 nbBombLeft:State.nbBombLeft shield:State.shield otherPlayerDead:State.otherPlayerDead stateotherplayer:State.stateotherplayer bombsOnTerrain:{List.append State.bombsOnTerrain Pos} posOtherPlayer:State.posOtherPlayer otherPlayerSpawnPos:State.otherPlayerSpawnPos)
         []bombExploded(Pos) then
            NewState = state(id:State.id spawned:State.spawned dead:State.dead spawnpos:State.spawnpos pos:State.pos point:State.point lives:State.lives livesOtherPlayer:State.livesOtherPlayer nbBombPlaced:State.nbBombPlaced-1 nbBombLeft:State.nbBombLeft shield:State.shield otherPlayerDead:State.otherPlayerDead stateotherplayer:State.stateotherplayer bombsOnTerrain:{RemoveBombFromList State.bombsOnTerrain Pos} posOtherPlayer:State.posOtherPlayer otherPlayerSpawnPos:State.otherPlayerSpawnPos)
         end
      NewState
      end
   end

   fun {StartPlayer ID}
      Stream Port OutputStream State
   in
      thread %% filter to test validity of message sent to the player
         OutputStream = {Projet2019util.portPlayerChecker Name ID Stream}
      end
      Port = {NewPort Stream}
      thread
      State = state(id:ID spawned:false dead:true spawnpos:nil pos:nil point:0 lives:Input.nbLives livesOtherPlayer:Input.nbLives nbBombPlaced:0 nbBombLeft:Input.nbBombs shield:0 otherPlayerDead:false stateotherplayer:false bombsOnTerrain:nil posOtherPlayer:nil otherPlayerSpawnPos:nil)
    {TreatStream OutputStream State}
      end
      Port
   end

   /*
   @Pre: Stream est une liste d'instructions a effectuer par le player 
   @Post: Permet de decoder les differentes isntructions et de les executer
   */
   
   proc {TreatStream Stream NewState}
      case Stream 
      of getID(ID)|T then
            {TreatStream T {GetID NewState ID}}
         []getState(ID State)|T then
            {TreatStream T {GetState NewState ID State}}
         []assignSpawn(Pos)|T then
            {TreatStream T {AssignSpawn Pos NewState}}
         []spawn(ID Pos)|T then
            {TreatStream T {Spawn NewState ID Pos}}
         []doAction(ID Action)|T then
            {TreatStream T {DoAction NewState ID Action}}
         []add(Type Option Result)|T then
            {TreatStream T {Add NewState Type Option Result}}
         []gotHit(ID Result)|T then
            {TreatStream T {GotHit NewState ID Result}}
         []info(Message)|T then
            {TreatStream T {Info NewState Message}}
      else skip
      end
   end
end
