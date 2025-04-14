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

## CR formula if you are interested in

```lua
local function calculateRating()
    local cr = 0

    -- Best Height (5K)
    cr = cr + 5000 * norm(MATH.icLerp(50, 6666, STAT.maxHeight), 6.2)

    -- Best Time (5K)
    cr = cr + 5000 * norm(MATH.icLerp(420, 76.2, STAT.minTime), -.5)

    -- Mod Completion (3K)
    cr = cr + 3000 * norm(MATH.icLerp(0, 18, getF10Completion()), .62)

    -- Mod Speedrun (2K)
    cr = cr + 2000 * norm(MATH.icLerp(0, 18, getSpeedrunCompletion()), .62)

    -- Zenith Points (3K)
    cr = cr + 3000 * norm(MATH.icLerp(0, 5e5, STAT.zp), 4.2)

    -- TODO: Achievement (5K)
    -- TODO: Daily Challenge (2K)
    cr = MATH.clamp(cr * 25000 / 18000, 0, 25000)

    return MATH.round(cr)
end
```

## Some todos (Will be implemented)

### Achievements

Same as tetr.io, but with more interesting contents!

Progress will be tracked in career, contribute to CR.

### Zenith points (ZP)

Earn `Altitude*Difficulty` each game, where Difficulty is the product of Difficulties of each mod.

Total ZP is soft-capped:
```lua
local function updateZP(oldZP, earn)
    return max(
        oldZP, -- Won't drop
        oldZP < earn * 26 and min(oldZP + earn, earn * 26) or -- Gain full before 26*zpGain
        earn * 26 + (oldZP - earn * 26) * (23 / 24) + (earn * 24) * (1 / 24) -- Slower from 26*zpGain, slower and slower when getting close to the hard-cap (50*zpGain)
    )
end
```

Total ZP will be recorded in career, contribute to CR.

Total ZP decay by 1% each day

Difficulty:

|   Mod    |  EX   |  NH   |  MS   |    GV     |    VL     |     DH     |  IN   |  AS   |     DP     |
| :------: | :---: | :---: | :---: | :-------: | :-------: | :--------: | :---: | :---: | :--------: |
| Upright  |  1.4  |  1.1  |  1.2  |    1.1    |    1.1    |    1.2     |  1.1  | 0.85  |    0.95    |
| Reversed |  2.6  |  1.6  |  2.0  | 1.2+.03*M | 1.2+.02*M | 1.6+.4*rIN |   X   |  1.1  | 2.2-.6*rEX |

> M = (Other) Mod Count  
> X = rNH ? (DP or rDP ? 2 : 2.2) : 1.6

`Hard Mod Decay = 0.98`  
applies `X-1` times, `X = number of "EX or Rev"`

### Daily Challenge

A random generated combo for each day, try to harvest most ZP in single run!

260% ZP gained with daily combo. (doesn't affect highscore)

Highscore will be recorded in career, contribute to CR.

Highscore decay by 6.26% each day.

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
