functor
export
   isTurnByTurn:IsTurnByTurn
   useExtention:UseExtention
   printOK:PrintOK
   nbRow:NbRow
   nbColumn:NbColumn
   map:Map
   nbBombers:NbBombers
   bombers:Bombers
   colorsBombers:ColorBombers
   nbLives:NbLives
   nbBombs:NbBombs
   thinkMin:ThinkMin
   thinkMax:ThinkMax
   fire:Fire
   timingBomb:TimingBomb
   timingBombMin:TimingBombMin
   timingBombMax:TimingBombMax
define
   IsTurnByTurn UseExtention PrintOK
   NbRow NbColumn Map
   NbBombers Bombers ColorBombers
   NbLives NbBombs
   ThinkMin ThinkMax
   TimingBomb TimingBombMin TimingBombMax Fire
in 


%%%% Style of game %%%%
   
   IsTurnByTurn = true
   UseExtention = false
   PrintOK = true


%%%% Description of the map %%%%
   
   NbRow = 7
   NbColumn = 7
   %Map = [
    %[1 1 1 1 1 1 1 1 1 1 1 1 1]
    %[1 4 0 2 2 2 2 2 2 2 0 4 1]
    %[1 0 1 3 1 2 1 2 1 2 1 0 1]
    %[1 2 2 2 3 2 2 2 2 3 2 2 1]
    %[1 0 1 2 1 2 1 3 1 2 1 0 1]
    %[1 4 0 2 2 2 2 2 2 2 0 4 1]
    %[1 1 1 1 1 1 1 1 1 1 1 1 1]]

    Map=[
    [1 1 1 1 1 1 1]
    [1 4 0 3 0 0 1]
    [1 0 2 0 2 0 1]
    [1 2 0 3 0 2 1]
    [1 0 2 0 2 0 1]
    [1 0 0 3 0 4 1]
    [1 1 1 1 1 1 1]]

   %Map = [ %Empty map2 to test some stuffes
    % [1 1 1 1 1 1 1 1 1 1 1 1 1]
     %[1 1 1 1 1 1 1 1 1 1 1 1 1]
     %[1 1 4 0 0 0 0 0 0 0 4 1 1]
     %[1 1 0 0 0 0 0 0 0 0 0 1 1]
     %[1 1 4 0 0 0 0 0 0 0 4 1 1]
     %[1 1 1 1 1 1 1 1 1 1 1 1 1]
     %[1 1 1 1 1 1 1 1 1 1 1 1 1]]


%%%% Players description %%%%

   NbBombers = 2
   Bombers = [player000bomber player082advancedPlayer]
   ColorBombers = [yellow red]

%%%% Parameters %%%%

   NbLives = 3
   NbBombs = 2
 
   ThinkMin = 500  % in millisecond
   ThinkMax = 2000 % in millisecond
   
   Fire = 3 
   TimingBomb = 3 
   TimingBombMin = 3000 % in millisecond
   TimingBombMax = 4000 % in millisecond

end
