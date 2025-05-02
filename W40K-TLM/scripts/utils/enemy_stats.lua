local enemy_stats = {

    -- **IMPORTANT** The engine needs to be restarted on any change in this script :)

    range = {

        -- Range Level 1
        [1] = {
            -- Stats
            health = 70,

            speed = 5.5,
            bulletSpeed = 15,

            meleeDamage = 15,
            rangeDamage = 5,

            detectionRange = 20,
            meleeAttackRange = 1,
            rangeAttackRange = 12,
            chaseRange = 6,

            maxBurstShots = 4,

            alertRadius = 20.0,

            priority = 1,



            -- **TIMERS**

            -- Saves the position of the player for the enemy shoot
            updateTargetInterval = 1.0,
            -- Time between bursts
            timeBetweenBursts = 1.0,
            -- Minimun time between shots of the same burst
            burstCooldown = 0.3,
            -- Time between stabs attacks
            stabCooldown = 2.0,
        },


        -- Range Level 2
        [2] = {
            -- Stats
            health = 90,

            speed = 5.5,
            bulletSpeed = 15,

            meleeDamage = 20,
            rangeDamage = 7,

            detectionRange = 20,
            meleeAttackRange = 1,
            rangeAttackRange = 12,
            chaseRange = 6,

            maxBurstShots = 4,

            alertRadius = 20.0,

            priority = 1,



            -- **TIMERS**
            updateTargetInterval = 1.0,
            timeBetweenBursts = 1.0,
            burstCooldown = 0.3,
            stabCooldown = 2.0,
            -- Invulnerable time of the range level 2 hability
            invulnerableTime = 5.0
        },

    },



    support = {

        -- Support Level 1
        [1] = {
            -- Stats
            health = 60,

            speed = 5,
            fleeSpeed = 7,

            enemyShield = 35,

            detectionRange = 20,
            shieldRange = 5,
            attackRange = 0,



            -- **Timers**

            -- Time between throwing a shield and be able to put another
            shieldCooldown = 5.0,
            -- When its in flee state, frequency of the support checking if ther is some enemy wich is able to get a shield
            checkEnemyInterval = 40.0
        },


        -- Support Level 2
        [2] = {
            -- Stats
            health = 75,

            speed = 5,
            fleeSpeed = 7,

            enemyShield = 50,

            damage = 30,

            detectionRange = 20,
            shieldRange = 5,
            attackRange = 10,



            -- **Timers**
            shieldCooldown = 4.0,
            checkEnemyInterval = 40.0
        }

    },



    tank = {

        -- Tank Level 1
        [1] = {
            -- Stats
            health = 250,

            speed = 3,
            tackleSpeed = 12,

            meleeDamage = 40,
            tackleDamage = 90,

            detectionRange = 20,
            meleeAttackRange = 3,

            statsIncrement = 1.5,
            statsDecrement = 0.33,

            priority = 2,



            -- **Timers**

            -- Time between melee attacks
            attackCooldown = 2.0,
            -- Time between tackles
            tackleCooldown = 6.0,
            -- Idle time before going after the player again
            idleDuration = 1.0,
            -- Total duration of Berserk mode
            berserkaDuration = 10.0
        },


        -- Tank Level 2
        [2] = {
            -- Stats
            health = 300,

            speed = 3,
            tackleSpeed = 12,

            meleeDamage = 60,
            tackleDamage = 110,

            detectionRange = 20,
            meleeAttackRange = 3,

            statsIncrement = 1.5,
            statsDecrement = 0.33,

            priority = 2,



            -- **Timers**
            attackCooldown = 2.0,
            tackleCooldown = 6.0,
            idleDuration = 1.0,
            berserkaDuration = 10.0
        }

    },



    kamikaze = {

        -- Kamikaze Level 1
        [2] = {
            -- Stats
            health = 45,

            speed = 7,

            damage = 40,

            detectionRange = 20,
            attackRange = 1,
            explosionRange = 3,

            priority = 3
        },

    },



    main_boss = {

        -- Main Boss Fase 1
        [1] = {
            -- Stats
            health = 1000,
            rageHealth = 400,
            bossShieldHealth = 50,

            speed = 2,

            meleeDamage = 120,
            rangeDamage = 80,

            detectionRange = 20,
            meleeAttackRange = 10,
            rangeAttackRange = 15,



            -- **Timers**

            -- Time between attacks
            attackCooldown = 0.5,
            -- Charge time before the lightning makes damage
            meleeAttackDuration = 2.0,
            -- Time when the lightning is active and making damage
            lightningDuration = 0.5,
            -- Duration of the fist attack before they disappear
            rangeAttackDuration = 10.0,
            -- The damage of the fist is called every time this timer ends (ex. The fists attack makes damage every second staying on it, it can be changed to 2s, 3s, 4s...etc.)
            fistsDamageCooldown = 1.0,
            -- Time before throwing the shield
            shieldCooldown = 15.0
        },


        -- Main Boss Fase 2
        [2] = {
            -- Stats
            bossShieldHealth = 70,
            totemHealth = 60,

            speed = 4,

            meleeDamage = 130,
            rangeDamage = 100,
            ultimateDamage = 350,

            detectionRange = 20,
            meleeAttackRange = 10,
            rangeAttackRange = 15,
            ultimateRange = 15,
            totemRange = 2,



            -- **Timers**
            attackCooldown = 0.5,
            meleeAttackDuration = 2.0,
            lightningDuration = 0.5,
            rangeAttackDuration = 10.0,
            fistsDamageCooldown = 1.0,
            shieldCooldown = 15.0,
            -- Time between ultimates
            ultiCooldown = 15.0,
            -- Time before the ultimate starts making damage
            ultiAttackDuration = 15.0,
            -- Time of the ultimate active and making damage
            ultiHittingDuration = 4.0,
            -- Time befor throwing a totem
            totemCooldown = 20.0
        }

    }



}

return enemy_stats
