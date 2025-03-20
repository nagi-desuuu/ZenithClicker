# Zenith Clicker

    Welcome to Zenith Clicker! Select required tarots to send players to scale the tower.  
    The higher the tower, the more tricky players will come!  
    There's no leaderboard, but how high can you reach?

> All Arts & Sounds from [TETR.IO](https://tetr.io) by osk, an online stacker game with Awesome Graphics and Musics!

Inspired by mod selection screen of tetr.io QP2, its interactive feel is really not good for quickly picking the mods needed,  
and there's still no convenient way to know which mods are included in a specific combo.

Powered by LÖVE & Zenitha & Lua ~~instead of slow web engine~~

Redesigned by MrZ  
Backgrounds reconstructed by DJ Asriel  
D-Din-Pro (Font) by Adrian Frutigеr  
AbhayaLibre-Regular (Font) by Mooniak

## How to play

> **By Community, may not accurate**

[work in progress]

## Design draft of Cliker League (Probably won't be implemented)

**Main idea**: Sending mod effect to opponent

Two players start the run same with single player.

**Sending Buffer**: your attacks will be turned into time (1 atk = 1 sec) and stored in this buffer.  
When it's not increasing for 3 seconds or taking time-damage, all times will be send to opponent.

The last card you activated is the effect which you will send.

**Cancelling**: Before sending `effect-time` to opponent, it will try to cancel the same effect you are carrying first, with a 2x multiplier.  
So you cannot force opponent EX if you have EX already.

**Sending**: After Cancelling, if there's extra time remain, your opponent will receive it.

Game ends when one of the players lose all HP.
