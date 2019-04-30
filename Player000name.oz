functor
import
   Input
   Browser
   Projet2019util
   Int
   List
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
   RemovePosFromList
   RemovePosFromListAux
   ListMap
   Spawn
   CheckPos
   UpdateMap
   ListMap
   ReadMap
in
   
   fun{CheckPos Map Pos}
      {Nth {Nth Map Pos.y} Pos.x}
   end

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


   %fun{ListMap Arg}
   %   fun{ReadMap Row Column}
   %      if(Row > Input.nbRow) then nil
   %      else
   %         if(Column == Input.nbColumn)
   %            if({List.nth {List.nth Input.map Row} Column} == Arg) then
   %               pt(x:Column y:Row)|{ReadMap Row+1 1}
   %            else
   %               {ReadMap Row+1 1}
   %            end
   %         else
   %            if({List.nth {List.nth Input.map Row} Column} == Arg) then
   %               pt(x:Column y:Row)|{ReadMap Row Column+1}
   %            else
   %               {ReadMap Row Column+1}
   %            end
   %         end 
   %      end
   %   end
   %   {ReadMap 1 1}
   %end
   
   
   
   fun{RemovePosFromList L Pos}
    case L of nil then nil
    []H|T then
       if {And H.x==Pos.x H.y==Pos.y} == true then
          {RemovePosFromList T Pos}
       else
          %{Browse T}
          H|{RemovePosFromList T Pos}
       end
    end
   end
   
   fun{IsOff State}
      if {Or State.spawned==true State.lives<1} then
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
         ID = null
         Pos = null
      else
         ID = State.id
         Pos = State.pos
      end
      State
   end

   fun{DoAction State ID Action}
      if {IsOff State} then
         ID = null
         Action = null
      else
         case Action of move(Pos) then
            ID = State.id
            State.pos = Pos
            []bomb(Pos) then
               if State.nbBombLeft > 0 then
                  ID = State.id
                  State.nbBombLeft = State.nbBombLeft - 1
                  State.nbBombPlaced = State.nbBombPlaced + 1
                  %%TODO add the bomb at the good position
               else
                  ID = null
               end
            else
               ID = null
               Action = null
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

   fun{GotHit State ID Result}
      if {IsOff State} == true then
         ID = null
         Result = null
      %elseif State.shield > 0
      %   ID = nil
      %   Result = nil
      %   State.shield = State.shield - 1
      else
         ID = State.id
         State.lives = State.lives - 1
         State.spawned = false
         Result = death(State.lives)
      end
      State 
   end

   fun{Info State Message}
      case Message 
      of spawnPlayer(ID Pos) then
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
      State
   end

   fun{StartPlayer ID}
      Stream Port OutputStream State
   in
      thread %% filter to test validity of message sent to the player
         OutputStream = {Projet2019util.portPlayerChecker Name ID Stream}
      end
      Port = {NewPort Stream}
      thread
      State = state(id:ID spawned:false dead:false spawnpos:nil pos:nil point:0 lives:Input.nbLives nbBombPlaced:0 nbBombLeft:Input.nbBombs shield:0 bombs:nil)
	 {TreatStream OutputStream State}
      end
      Port
   end

   
   proc{TreatStream Stream NewState}
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
