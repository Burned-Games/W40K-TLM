local enemy_stats = {



    range = {

        [1] = {
            health = 95,
            speed = 3,
            bulletSpeed = 15,
            meleeDamage = 15,
            rangeDamage = 5,
            detectionRange = 25,
            meleeAttackRange = 1,
            rangeAttackRange = 10,
            chaseRange = 8,
            maxBurstShots = 4,
            priority = 1
        },

        [2] = {
            health = 110,
            speed = 4,
            bulletSpeed = 15,
            meleeDamage = 25,
            rangeDamage = 10,
            detectionRange = 25,
            meleeAttackRange = 1,
            rangeAttackRange = 10,
            chaseRange = 8,
            maxBurstShots = 4,
            priority = 1
        },

        [3] = {
            health = 140,
            speed = 5,
            bulletSpeed = 15,
            meleeDamage = 35,
            rangeDamage = 15,
            detectionRange = 25,
            meleeAttackRange = 1,
            rangeAttackRange = 10,
            chaseRange = 8,
            maxBurstShots = 4,
            priority = 1
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

        [1] = {
            health = 250,
            speed = 2,
            tackleSpeed = 13,
            meleeDamage = 40,
            tackleDamage = 100,
            detectionRange = 20,
            meleeAttackRange = 3,
            priority = 2
        },

        [2] = {
            health = 300,
            speed = 2,
            tackleSpeed = 13,
            meleeDamage = 60,
            tackleDamage = 180,
            detectionRange = 20,
            meleeAttackRange = 3,
            priority = 2
        }

    },



    kamikaze = {

        [1] = {
            health = 45,
            speed = 10,
            damage = 40,
            detectionRange = 20,
            attackRange = 1,
            explosionRange = 5,
            priority = 3
        },

        [2] = {
            health = 51,
            speed = 12,
            damage = 70,
            detectionRange = 20,
            attackRange = 1,
            explosionRange = 7,
            priority = 3
        }

    }



}

return enemy_stats
