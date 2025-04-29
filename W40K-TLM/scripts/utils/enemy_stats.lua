local enemy_stats = {

    -- **IMPORTANT** The engine needs to be restarted on any change in this script :)

    range = {

        -- Range Level 1
        [1] = {
            -- Stats
            health = 95,

            speed = 5,
            bulletSpeed = 15,

            meleeDamage = 15,
            rangeDamage = 5,

            detectionRange = 25,
            meleeAttackRange = 1,
            rangeAttackRange = 16,
            chaseRange = 6,

            maxBurstShots = 4,

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
            health = 110,

            speed = 7,
            bulletSpeed = 15,

            meleeDamage = 25,
            rangeDamage = 10,

            detectionRange = 25,
            meleeAttackRange = 1,
            rangeAttackRange = 10,
            chaseRange = 8,

            maxBurstShots = 4,

            priority = 1,



            -- **TIMERS**
            updateTargetInterval = 1.0,
            timeBetweenBursts = 1.0,
            burstCooldown = 0.3,
            stabCooldown = 2.0,
        },


        -- Range Level 3
        [3] = {
            --Stats
            health = 140,

            speed = 9,
            bulletSpeed = 15,

            meleeDamage = 35,
            rangeDamage = 15,

            detectionRange = 25,
            meleeAttackRange = 1,
            rangeAttackRange = 10,
            chaseRange = 8,

            maxBurstShots = 4,

            priority = 1,



            -- **TIMERS**
            updateTargetInterval = 1.0,
            timeBetweenBursts = 1.0,
            burstCooldown = 0.3,
            stabCooldown = 2.0,
            -- Invulnerable time of the range level 3 hability
            invulnerableTime = 5.0
        }

    },



    support = {

        [1] = {
            health = 50,
            speed = 5,
            fleeSpeed = 7,
            enemyShield = 35,
            damage = 0,
            detectionRange = 10,
            shieldRange = 5,
            attackRange = 0
        },

        [2] = {
            health = 75,
            speed = 5,
            fleeSpeed = 2,
            enemyShield = 70,
            damage = 30,
            detectionRange = 10,
            shieldRange = 5,
            attackRange = 10
        }

    },



    tank = {

        -- Tank Level 1
        [1] = {
            -- Stats
            health = 250,

            speed = 2,
            tackleSpeed = 13,

            meleeDamage = 40,
            tackleDamage = 80,

            detectionRange = 20,
            meleeAttackRange = 3,

            priority = 2,



            -- **Timers**

            -- Time between melee attacks
            attackCooldown = 3.0,
            -- Time between tackles
            tackleCooldown = 10.0,
            -- Idle time before going after the player again
            idleDuration = 1.0
        },


        -- Tank Level 2
        [2] = {
            -- Stats
            health = 300,

            speed = 2,
            tackleSpeed = 13,

            meleeDamage = 60,
            tackleDamage = 180,

            detectionRange = 20,
            meleeAttackRange = 3,

            statsIncrement = 1.5,
            statsDecrement = 0.33,

            priority = 2,



            -- **Timers**
            attackCooldown = 3.0,
            tackleCooldown = 10.0,
            idleDuration = 1.0,
            -- Total duration of Berserk mode (level 2 hability)
            berserkaDuration = 180.0
        }

    },



    kamikaze = {

        -- Kamikaze Level 1
        [1] = {
            -- Stats
            health = 45,

            speed = 10,

            damage = 40,

            detectionRange = 20,
            attackRange = 1,
            explosionRange = 5,

            priority = 3
        },


        -- Kamikaze Level 2
        [2] = {
            -- Stats
            health = 51,

            speed = 12,

            damage = 70,

            detectionRange = 20,
            attackRange = 1,
            explosionRange = 7,

            priority = 3
        }

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
