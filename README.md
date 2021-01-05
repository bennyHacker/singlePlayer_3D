# singlePlayer_3D
 -----------------------------------------------
 ! ! ! WARNING ! ! ! WARNING ! ! ! WARNING ! ! !
 -----------------------------------------------
 
 Warning: this program uses "Robot", which locks the mouse in the center of the 
 screen (this enables an 'unlimited free look effect').  If you press 'run' and 
 then click on another window/program, the mouse will be locked in the center 
 of the screen and you may be unable to exit.
 
 Make sure not to click anything after pressing 'run', and remember to use ESC
 to close the program.
 
 May contain graphic violence (blood, weapons, zombies)
 
 
 
 Thankyou for checking out my program! This sketch combines 2D and 3D geometry
 to achieve a basic 3D FPS engine.
 
 All of the level geometry is made with 3-point, triangular planes. The two main
 classes, characterBase and projectile, are tested against these planes within a
 quadTree for maximum efficiency
 
 Feel free to utilize the code any way you want!
 
 
 If you're wondering how the file loading works:
 
 - all data is contained within a single text file
 - the very first string is the player's spawn position (XYZ, seperated by commas)
 - for every next string, it checks if the string starts with a 'p' (if so, then
 it will generate a plane with the information in that string)
 - the data is as followed: (seperated by commas)
 - P1.x, P1.y, P1.z, P2.x, P2.y, P2.z, P3.x, P3.y, P3.z, U1, V1, U2, V2, U3, V3, texture
 - (P1, P2 and P3 are the points of the plane, next are the UV coordinates, and the texture as an int)
 - any custom data type can be added (for instance, I can add 'zombie data' that starts
 with a 'z' instead of a 'p')
