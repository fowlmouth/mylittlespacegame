# just a little space game

based on https://github.com/Athaudia/cutespacegame

You'll also need the game gata to play. At the moment this is a 80MB download that unpacks to 100MB. (dropbox/spacegame-data.7z)[http://dl.dropbox.com/u/58078993/spacegame-data.7z]

# dependencies

<b>Ruby 1.9.3*</b>

Gosu 0.7.41

Chingu 0.8.1 

Chipmunk 5.3.4.5


Install them with gems

*Recommend Ruby 1.9.3 for faster loading time, but 1.9.2 should work fine
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
