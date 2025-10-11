return {
    [''] = STRING.trimIndent [[
        FLIP THE TAROT CARDS IN THIS MODERN YET UNFAMILIAR OFFLINE CLICKER.
        PLAY TO IMPROVE YOUR SKILLS, AND GAIN CR FROM VARIOUS MODS
        - THE CLICKER FUTURE IS YOURS!
    ]],
    notFinished = STRING.trimIndent [[
        FLIP THE TAROT CARDS IN THIS MODERN YET UNFAMILIAR OFFLINE CLICKER.
        PLAY TO IMPROVE YOUR SKILLS, AND GAIN CR FROM VARIOUS MODS
        - MASTER SELECTED MOD/COMBO TO UNLOCK THE DEVELOPER COMMENTARY!
    ]],
    noComment = STRING.trimIndent([[
        SELECTED MOD/COMBO DOESN'T HAVE DEVELOPER COMMENTARY.
        TRY ANOTHER COMBO AND COME BACK :>
                            - THE CLICKER FUTURE IS YOURS!      —— MrZ
    ]], true),
    ['EX'] = STRING.trimIndent [[
        A mod that appears simple but actually requires much skill and significantly reduces the final score.
        Like QP2, this mod is designed to punish mistakes more severely and make game less lenient.
        So I chose "smaller spacing + deselect all cards on wrong commit", along with faster XP leaking in QP2.
    ]],
    ['NH'] = STRING.trimIndent [[
        A mod with very low presence, pros can almost ignore it like no mod at all.
        Originally, I intended to remove a feature (the reset button), similar to how it works in Tetris,
        but that conflicted with the later design of AS. So I decided to change it to "No cancel".
    ]],
    ['MS'] = STRING.trimIndent [[
        A mod which is way too harder at first because shuffling cards just brutally slows you down.
        I interpreted literally as shuffling the cards since there's no "garbage lines".
        So it becomes significantly harder than QP2, plays so awful, and finally got nerfed many times.
    ]],
    ['GV'] = STRING.trimIndent [[
        Possibly the weakest mod than others, pros can completely ignore it.
        In Tetris, "increasing gravity" is similar to "forced locking", the equivalent here is forced committing.
        My aim is let everyone enjoy mods, so I made it very lenient to reduce the difficulty of combos.
    ]],
    ['VL'] = STRING.trimIndent [[
        A rather interesting mod that introduces clicking technique and endurance to the game.
        "receiving double garbages" in Tetris can correspond to "clicking the mouse twice as much".
        QP2 also cancel double, so I made canceling still one-click. Feels good but it actually leads to more mistakes —pretty interesting, isn't it?
    ]],
    ['DH'] = STRING.trimIndent [[
        Another mod with low presence, but it does increase the difficulty to some extent.
        Though we don't have garbage lines, "harder-to-clear garbage lines" can correspond to "more complex quests".
        So I designed DH to increase the expected number of mods in quests, while also slightly reducing the variance for balance.
    ]],
    ['IN'] = STRING.trimIndent [[
        A pretty cool mod that presents the "invisible" effect in a different way. Obviously, real invisible would be too difficult for an upright mod,
        So I took the approach of "hiding texts on card and colors of quests", this increases reading difficulty, creating a sensation similar to invisibility.
        Meanwhile, this also shows the design on the card back, strengthening the association between mods and their corresponding colors.
    ]],
    ['AS'] = STRING.trimIndent [[
        Just like in QP2, is a mod that "seems to have a positive effect?!", so I considered "significant buff" —play with keyboard!
        Thus, AS became an almost purely positive mod. For negative penalty. Taking inspiration from QP2's "consecutive same clear",
        "flipping a card twice" could be punished, with wounded sound effect and small punishments. Btw, Allspin surely spin all cards instead of reset!
    ]],
    ['DP'] = STRING.trimIndent [[
        The mod with the lowest development cost-effectiveness —took about three days to implement, barely worth it since it introduces the revive run.
        Since this is a single-player mini-game, online multiplayer wasn't considered. So... split the health bar into two and treat it as two players!
        To make switching easier, I chose "selecting DP card" as the condition. It also naturally switches a few times as DP appeared in quests. Nice!
    ]],

    ['rEX'] = STRING.trimIndent [[
        Exactly same with EX in QP2, even "less kill bonus", yeah, I treat "passing a quest containing DP mod" as a kill (though it's obviously much weaker)
        Until I write this, there are still only 2 players mastered rEX in QP2, way too hard for everyone to even have a try.
        I tried to shrink cards spacing furthermore, but that turns out to be too hard, so I abandoned this idea. But you could try this challenge with...
        Anyways, Zenith Clicker's aim is to let everyone enjoy all mods! Just practice a few weeks to beat rEX here! Or use AS to skip the challenge :>
    ]],
    ['rNH'] = STRING.trimIndent [[
        I want to reproduce the feeling of "classic" like what QP2 does, so I tried many combinations of "limited next queue" "no cancel" "no reset button".
        And finally I decided to make it "limited next queue" + "no auto cancel", and "remove +1 atk on perfect pass".
        Though it doesn't look like very "classic", it does need you read the only next quest and plan ahead, just like classical Tetris.
    ]],
    ['rMS'] = STRING.trimIndent [[
        What about... shuffling cards after each quest? Sounds evil but that's how reversed mods should be like, right?
        Well, I still want it to be playable for skilled players, here's the secret: the last clicked card and its neighbors won't be shuffled on pass.
        Being lenient, it's the key to make a game enjoyable, and sometimes helps creating more possibility of strategies. Go try speedrunning with it now!
    ]],
    ['rGV'] = STRING.trimIndent [[
        20G Tetris players love pure speed. So let's go faster, just faster, and nothing else changed.
        And being lenient: pause the timer for a while on passing previous quest, and reset the timer on wrong commit & reset cards.
        You said you didn't noticed that? Good, now you know how many details I added :>
        Btw do you wanna take a more exciting challenge? Go activating rGV + nightco... oops maybe I shouldn't give you hint about this XD
    ]],
    ['rVL'] = STRING.trimIndent [[
        Double clicks? Quadruple clicks! Due to health reasons, Left+Right click is allowed here, it's still very tiring to double double clicks for each card,
        and you could even use keyboard to further reduce the inputs, but that's also harder to coordinate. Which strat is the best? Up to you.
        Oh and don't forget that in QP2 there's only triple garbages but no triple cancelling, so you need to click 4 times to cancel a card too :>
    ]],
    ['rDH'] = STRING.trimIndent [[
        When I came to design this mod, QP2's rDH was still "messy garbage + no cancelling", not the current "messy garbage + dig to attack" one
        so I had no idea about how rDH should be, then I saw the "naming every combo" spreadsheet in tetrio community, it could be the answer...?
        Anyways it became the answer, rDH changes all quests into "wtf is this thing", maybe it's not related but at least it's so fun!
    ]],
    ['rIN'] = STRING.trimIndent [[
        Time to play real invisible! Reversed invisible should be really invisible. Let's hide quests after a few seconds...
        Wait, should we just hide all of them, which could be too hard, or only hiding current one, which could be too easy if you just pre-read one quest?
        Maybe I can take the compromise: current one first, then the latter ones. And don't forget to be lenient: show quests when player make mistake.
        Btw can you imagine a challenge that both quests and your cards are invisible?
    ]],
    ['rAS'] = STRING.trimIndent [[
        Just like in QP2, rAS makes player stronger but also more fragile. So let's take the +1 attack on B2B x 4+,
        and make the punishment stricter: flipping a card twice will mess up more cards, and you cannot cancel the burning effect.
        Well, it's still a strong buff if you are skilled enough, enjoy it!
    ]],
    ['rDP'] = STRING.trimIndent [[
        Why we can only play rDP in QP2 for only 1 weeks :sob: :sob: :sob: Let's play rDP forever in Zenith Clicker!
        Same as DP, except your attacks will also be sent to the other player, you have to master switching players now.
        Though the "backfire" doesn't give you garbage to send more, your max rank is still limited just like in QP2.
    ]],

    ['uEX'] = STRING.trimIndent [[
        No more leniency. Let's tighten cards spacing.
    ]],
    ['uNH'] = STRING.trimIndent [[
        No more leniency. No XP protection,  no Surge attack.
    ]],
    ['uMS'] = STRING.trimIndent [[
        No more leniency. Let's shuffle the whole deck on each pass.
    ]],
    ['uGV'] = STRING.trimIndent [[
        No more leniency. Timer starts immediately and never resets.
    ]],
    ['uVL'] = STRING.trimIndent [[
        No more leniency. Everything must be clicked 4 times.
    ]],
    ['uDH'] = STRING.trimIndent [[
        No more leniency. All phrases are scrambled letter by letter.
    ]],
    ['uIN'] = STRING.trimIndent [[
        No more leniency. Quests will never show gain.
    ]],
    ['uAS'] = STRING.trimIndent [[
        No more leniency. Flipping a card twice ends the run.
    ]],
    ['uDP'] = STRING.trimIndent [[
        No more leniency. 50% more damage to ally.
    ]],
}
