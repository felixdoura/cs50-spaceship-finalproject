# Felix Doura - Spaceship Game
#### Video Demo:  [<URL HERE>](https://www.youtube.com/watch?v=YY4YiWow5bM)
#### Description:

Well, first of all, I would like to thank the staff of CS50 for this course, the EDX platform in which I learned about the course, my family and friends.
This was an awesome experience and I learned a lot about the computing programming

Regarding this project, I have alwasy been interested in science fiction, I am a Star Wars fan and a game ethusiast. Aswell I always dreamed about making a game of my own and in this opportunity I learned how to do it.
In the past I also had some approaches to Unity and Godot engines but with LOVE2D i found a great way to do some things that I thoung, months ago, impossible to me.

The game is pretty simple, I made a 2D spaceship shooting game. The player has a base 100 health and enemies have 1 health. The objective of the game is to defeat 15 enemies while trying to avoid the enemies shots.
Enemies make 15% health damage on the player when they get a hit, and upon a colission with the playe, the player gets destroyed.

There is a mechanic in the game that allows the player to pause the game, quit, or restart
When the player is defeated, an animation displays the ship exploting and allows the player either to quit or to reset the game.

While developing the game I found some problems and had to change my vision on the ongoing of the project. I wanted to add a final boss that appeared on the right side of the screen but when counting on the enemies defetead there was a bug that crashed the game. I tried to come with a solution to that but I found that just destroying regular enemies would be a good solution on winning the game.
When the objective of defeating 15 enemies, a winning message will pop, also allowing the player to restart and play again, or to quit.

About the boundaries of the screen I thought about not limiting the ship to exit the screen, since this allows more movement and lets the player avoiding the hits.
Animations ocurrs using a piece of code that I think its a clever way to use less images. Using frameWidth and frameHeight, I explicity put the number of pixels that the sprites should have. And talking about sprites, there are some assets that I didn't use on the file, but those sprites may be useful for making this project bigger.

The projectiles physics are pretty simple, they follow a linear path towars the player of from the player, and the enemy ships always face the player using the angle of the sprite.

This has been an awesome project for me because I pushed my limits, learned many new approaches to problems and when achieving the result the feeling of joy was indescriptible.

