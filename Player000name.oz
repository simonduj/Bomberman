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
      State.spawnpos = Pos
      State
   end

   /*
   @Pre: ID et Pos passees en argument ne sont pas liees
   @Post: Retourne le meme etat lie la position a spawnpos et attribue les valeurs correctes a Pos et ID
   */

   fun {Spawn State ID Pos}
      if {Or State.spawned==true State.nbLives<1} then
         ID = null
         Pos = null
      else
         ID = State.id
         Pos = State.spawnpos
         State.spawned = true
         State.pos = Pos
      end
      State
   end

   /*
   @Pre: ID et Action passees en argument ne sont pas liees
   @Post: Retourne le meme etat et lie la variable ID a sa valeur dans State et Action a la valeur que le joueur va effectuer (determinee de maniere aleatoire)
   */

   fun {DoAction State ID Action}
   local A in
      if {IsOff State} then
         ID = null
         Action = null
      else
         A = {Binary}
         if A == 0 then
            RandomNewPos = {RandomMove State.pos}
               {DoMove State RandomNewPos}
               ID = State.id
               Action = move(RandomNewPos)
         else 
            if State.nbBombLeft > 0 then
                  ID = State.id
                  State.nbBombLeft = State.nbBombLeft - 1
                  State.nbBombPlaced = State.nbBombPlaced + 1
            else RandomNewPos = {RandomMove State.pos}
            end
         end
      end 
      State
   end
   end

   proc{DoMove State Pos}
      State.pos = Pos
   end

   fun {Add State Type Option Result}
      case Type of bomb then
         if {Int.isNat Option} == true then
            State.nbBombLeft = State.nbBombLeft + Option
            Result = State.nbBombLeft
         else
            Result = null
            raise unknownOption('Option not recognized by the Player '#Option) end
         end
      []point then
         if {Int.isNat Option} == true then
            State.point = State.point + Option
            Result = State.point
         else
            Result = null
            raise unknownOption('Option not recognized by the Player '#Option) end
         end
      []shield then
         if {Int.isNat Option} == true then
            State.shield = State.shield + Option
            Result = State.shield
         else
            Result = null
            raise unknownOption('Option not recognized by the Player '#Option) end
         end
      []life then
         if {Int.isNat Option} == true then
            State.lives = State.lives + Option
            Result = State.lives
         else
            Result = nil
            raise unknownOption('Option not recognized by the Player '#Option) end
         end
      else
         raise unknownAdd('Add not recognised by the Player '#Type) end
      end
      State
   end

   /*
   @Pre: ID et Result passees en argument ne sont pas liees
   @Post: Retourne le meme etat et lie la variable ID a sa valeur dans State et Result a death(State.lives)
   */

   fun {GotHit State ID Result}
      if {IsOff State} == true then
         ID = null
         Result = null
      elseif State.shield > 0 then
         ID = null
         Result = null
         State.shield = State.shield - 1
      else
         ID = State.id
         State.lives = State.lives - 1
         State.spawned = false
         Result = death(State.lives)
      end
      State 
   end

   /*
   @Pre: Prend en argument un message
   @Post: Le message est decode et l'etat est mis a jour accordément a celui ci
   */

   fun {Info State Message}
      case Message 
      of spawnPlayer(ID Pos) then
         if ID == State.id then
            State.spawnpos = Pos
            State.spawned = true
            State.dead = false
         else
            State.posOtherPlayer = Pos
            State.stateotherplayer = true
            State.otherPlayerAlive = true
         end
      []movePlayer(ID Pos) then
         if ID == State.id then
            State.pos = Pos
         else State.posOtherPlayer = Pos
         end
      []deadPlayer(ID) then
         if State.id == ID then
            State.spawned = false
            if State.lives == 1 then
               State.dead = true
            else
               State.lives = State.lives-1
            end
         else
            State.stateotherplayer = false
            if State.livesOtherPlayer == 1 then
               State.otherPlayerDead = true
            else
               State.livesOtherPlayer = State.livesOtherPlayer - 1
            end
         end
      []bombPlanted(Pos) then
         {List.append State.bombsOnTerrain Pos}
      []bombExploded(Pos) then
         State.bombs = {RemoveBombFromList State.bombsOnTerrain Pos}

     end
      State
   end

   fun {StartPlayer ID}
      Stream Port OutputStream State
   in
      thread %% filter to test validity of message sent to the player
         OutputStream = {Projet2019util.portPlayerChecker Name ID Stream}
      end
      Port = {NewPort Stream}
      thread
      State = state(id:ID spawned:false dead:true spawnpos:nil pos:nil point:0 lives:Input.nbLives livesOtherPlayer:Input.nbLives nbBombPlaced:0 nbBombLeft:Input.nbBombs shield:0 bombs:nil otherPlayerDead:false stateotherplayer:false bombsOnTerrain:nil posOtherPlayer:nil)
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
