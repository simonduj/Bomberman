functor
import
   Input
   Browser
   Projet2019util
   Int
   List
export
   portPlayer:StartPlayer
   OutputStream
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
   Message
   RemovePosFromList
in
   
   fun{RemovePosFromList L Pos}
      fun{RemovePosFromListAux L Pos Acc}
         case L of nil then nil
         else
            if L.1 == pos(x:Pos.x y:Pos.y) then {List.append Acc L.2}
            else {RemovePosFromListAux L.2 Pos {List.append Acc L.1}}
         end
      end
      {RemovePosFromListAux L Pos nil}
   end
   
   fun{IsOff State}
      if State.spawned == true or State.NbLives <= 0 then
         true
      else
         false 
      end
   end
   
   fun{GetID State ID}
      ID = State.id
      State
   end

   fun{GetState State ID Resp}
      ID = State.id
      Resp = State.spawned
      State
   end

   fun{AssignSpawn Pos State}
      State.spawnpos = Pos
      State
   end

   fun{Spawn State ID Pos}
      if {IsOff State} then
         ID = nil
         Pos = nil
      else
         ID = State.id
         Pos = State.pos
      end
      State
   end

   fun{DoAction State ID Pos Action}
      if {IsOff State} then
         ID = nil
         Action = nil
      else
         case Action of Move(Pos) then
            ID = State.id
            State.pos = Pos
            []Bomb(Pos) then
               if State.nbBombLeft > 0 then
                  ID = State.id
                  State.nbBombLeft = State.nbBombLeft - 1
                  State.nbBombPlaced = State.nbBombPlaced + 1
               else
                  ID = nil
               end
            else
               ID = nil
               Action = nil
         end
      end
      State
   end

   fun{Add State Type Option Result}
      case Type of bomb then
         if {Int.isNat Option} == true then
            State.nbBombLeft = State.nbBombLeft + Option
            Result = State.nbBombLeft
         else
            raise unknownOption('Option not recognized by the Player '#Option) end
         end
      []point then
         if {Int.isNat Option} == true then
            State.lives = State.lives + Option
            Result = State.lives
         else
            raise unknownOption('Option not recognized by the Player '#Option) end
         end
      else
         raise unknownAdd('Add not recognised by the Player '#Type)
      end
      State
   end

   fun{GotHit State ID Result}
      if {IsOff State} == true then
         ID = nil
         Result = nil
      elseif State.shield > 0
         ID = nil
         Result = nil
         State.shield = State.shield - 1
      else
         ID = State.id
         State.lives = State.lives - 1
         State.spawned = false
         Result = death(State.lives)
      end
      State 
   end

   fun{Message State Message}{
      case Message of nil then nil
      []spawnPlayer(ID Pos) then
         State.spawnpos = Pos
         State.spawned = true
      []movePlayer(ID Pos) then
         State.pos = Pos
      []deadPlayer(ID) then
         State.dead = true
         State.lives = 0
      []bombPlanted(Pos) then
         {List.append State.bombs Pos}
      []bombExploded(Pos) then
         State.bombs = {RemovePosFromList State.bombs Pos}

      end
   }

   fun{StartPlayer ID}
      Stream Port OutputStream
   in
      thread %% filter to test validity of message sent to the player
         OutputStream = {Projet2019util.portPlayerChecker Name ID Stream}
      end
      Port = {NewPort Stream}
      thread
      State = state(id:ID spawned:false dead:false spawnpos:nil pos:nil point:0 lives:Input.NbLives nbBombPlaced:0 nbBombLeft:Input.nbBombs shield:0 bombs:nil)
	 {TreatStream OutputStream State}
      end
      Port
   end

   
   proc{TreatStream Stream NewState} %% TODO you may add some arguments if needed
      %% TODO complete
      case Stream of nil then skip
      []H|T then
         case H 
         of nil then skip
         []getID(ID) then
            {TreatStream T {GetID NewState ID}}
         []getState(ID State) then
            {TreatStream T {GetState NewState ID State}}
         []assignSpawn(Pos) then
            {TreatStream T {AssignSpawn Pos NewState}}
         []spawn(ID Pos) then
            {TreatStream T {Spawn NewState ID Pos}}
         []doAction(ID Action) then
            {TreatStream T {DoAction NewState ID Pos Action}}
         []add(Type Option Result) then
            {TreatStream T {Add NewState Type Option Result}}
         []gotHit(ID Result) then
            {TreatStream T {GotHit NewState ID Result}}
         []info(Message) then
            {TreatStream T {Info NewState Message}}
         else skip
      else skip
   end
   

end
