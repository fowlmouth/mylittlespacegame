# just a little space game

based on https://github.com/Athaudia/cutespacegame

# requirements

<b>Ruby 1.9.2+</b>

Gosu 0.7.37

Chingu 0.8.1 

Chipmunk 5.3.4.5


Install them with gems

Recommend Ruby 1.9.3 for faster loading time
  The only thing from 1.9.3 is rand(...) and that's sporatic, have a compatibility hack for it in main.rb

# TODO

Ships dying

Waves of enemies

AI that works together, cooperating in their sham of a life

Game types (CTF, Soccer, etc)

Slotted weapons, prizes and such

Ship rolling - done

# Tests

Wormhole Gravity: `./main.rb wh` I'm not a scientist, and bad at math, so its taking a while to get this right

Static Objects: `./main.rb st` This will probably turn into a map editor

Turrets: `./main.rb tt` Turrets work satisfactory now but still need some tweaking
