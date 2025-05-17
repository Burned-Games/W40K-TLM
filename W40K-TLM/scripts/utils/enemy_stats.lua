local enemy_stats = {

    -- **IMPORTANT** The engine needs to be restarted on any change in this script :)

    range = {

        -- Range Level 1
        [1] = {
            -- Stats
            health = 100,

            speed = 5.5,
            bulletSpeed = 15,

            meleeDamage = 10,
            rangeDamage = 4,

            detectionRange = 15,
            meleeAttackRange = 1,
            rangeAttackRange = 13,
            chaseRange = 4,

            maxBurstShots = 4,

            alertRadius = 15,

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
            health = 120,

            speed = 5.5,
            bulletSpeed = 15,

            meleeDamage = 15,
            rangeDamage = 6,

            detectionRange = 15,
            meleeAttackRange = 1,
            rangeAttackRange = 13,
            chaseRange = 4,

            maxBurstShots = 4,

            alertRadius = 15.0,

            priority = 1,



            -- **TIMERS**
            updateTargetInterval = 1.0,
            timeBetweenBursts = 1.0,
            burstCooldown = 0.3,
            stabCooldown = 2.0,
            -- Invulnerable time of the range level 2 hability
            invulnerableTime = 2.0
        },

    },



    support = {

        -- Support Level 1
        [1] = {
            -- Stats
            health = 80,

            speed = 5,
            fleeSpeed = 7,
            bulletSpeed = 15,

            enemyShield = 50,

            supportDamage = 10,

            maxBurstShots = 4,

            detectionRange = 15,
            shieldRange = 5,
            attackRange = 0,



            -- **Timers**

            -- Time between throwing a shield and be able to put another
            shieldCooldown = 4.0,
            -- When its in flee state, frequency of the support checking if ther is some enemy wich is able to get a shield
            checkEnemyInterval = 40.0,

            timeBetweenBursts = 5.0,
            -- Minimun time between shots of the same burst
            burstCooldown = 0.5
        },


        -- Support Level 2
        [2] = {
            -- Stats
            health = 95,

            speed = 5,
            fleeSpeed = 7,
            bulletSpeed = 15,

            enemyShield = 70,

            supportDamage = 20,

            maxBurstShots = 4,

            detectionRange = 15,
            shieldRange = 5,
            attackRange = 10,



            -- **Timers**
            shieldCooldown = 3.0,
            checkEnemyInterval = 40.0,
            timeBetweenBursts = 2.0,
            -- Minimun time between shots of the same burst
            burstCooldown = 0.2
        }

    },



    tank = {

        -- Tank Level 1
        [1] = {
            -- Stats
            health = 250,

            speed = 3,
            tackleSpeed = 12,

            meleeDamage = 30,
            tackleDamage = 65,

            detectionRange = 15,
            meleeAttackRange = 3,

            statsIncrement = 1.5,
            statsDecrement = 0.33,

            priority = 2,

            alertRadius = 20.0,

            -- **Timers**

            -- Time between melee attacks
            attackCooldown = 2.0,
            -- Time between tackles
            tackleCooldown = 6.0,
            -- Idle time before going after the player again
            idleDuration = 1.0,
            -- Total duration of Berserk mode
            berserkaDuration = 5.0
        },


        -- Tank Level 2
        [2] = {
            -- Stats
            health = 300,

            speed = 3,
            tackleSpeed = 12,

            meleeDamage = 60,
            tackleDamage = 110,

            detectionRange = 15,
            meleeAttackRange = 3,

            statsIncrement = 1.5,
            statsDecrement = 0.33,

            priority = 2,

            alertRadius = 20.0,

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
            health = 55,

            speed = 7,

            damage = 40,

            detectionRange = 15,
            attackRange = 1,
            explosionRange = 3,

            priority = 3,
            
            alertRadius = 20.0,
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

            detectionRange = 40,
            meleeAttackRange = 10,
            rangeAttackRange = 30,

            fistTargetScale = 3,



            -- **Timers**

            -- Time between attacks
            attackCooldown = 0.5,
            -- Charge time before the lightning makes damage
            meleeAttackDuration = 2.0,
            -- Time when the lightning is active and making damage
            lightningDuration = 0.5,
            -- Duration of the fist attack before they disappear
            rangeAttackDuration = 2.0,
            -- The damage of the fist is called every time this timer ends (ex. The fists attack makes damage every second staying on it, it can be changed to 2s, 3s, 4s...etc.)
            fistsDamageCooldown = 1.0,
            -- Time before throwing the shield
            shieldCooldown = 8.0
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

            detectionRange = 50,
            meleeAttackRange = 10,
            rangeAttackRange = 30,
            totemRange = 2,

            fistTargetScale = 3,



            -- **Timers**
            attackCooldown = 0.5,
            meleeAttackDuration = 2.0,
            lightningDuration = 0.5,
            rangeAttackDuration = 2.0,
            fistsDamageCooldown = 1.0,
            shieldCooldown = 8.0,
            -- Time between ultimates
            ultiCooldown = 15.0,
            -- Time before the ultimate starts making damage
            ultiAttackDuration = 15.0,
            -- Time of the ultimate active and making damage
            ultiHittingDuration = 2.5,
            -- Time befor throwing a totem
            totemCooldown = 20.0
        }

    }



}

return enemy_stats
