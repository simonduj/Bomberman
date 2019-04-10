functor
import
   GUI
   Input
   PlayerManager
   Browser
define
   Port
   Window
in
   %% Implement your controller here
   Port = {GUI.portWindow}
   {GUI.buildWindow Port}
   {Browser.browse Port}
end
