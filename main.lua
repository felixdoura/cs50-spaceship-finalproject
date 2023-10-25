-- -------------------------------
-- ---------- VARIABLES ----------
-- -------------------------------

-- Game State

local GameState = {
    PLAYING = 1,
    PAUSED = 2,
    GAME_OVER = 3,
    PLAYER_EXPLOSION = 4,
    PLAYER_WINS = 5
}

local gameState = GameState.PLAYING
isPaused = false
isPlayerExploding = false

-- Background variables
local background = love.graphics.newImage("/assets/background/spacebackground.jpg")
local backgroundX = 0
local backgroundSpeed = 100

-- Player variables
player = {x = 200, y = 200, speed = 250, img = nil}
player.angle = 0
playerHealth = 100 
maxPlayerHealth = 100 

    -- Player explosion
local explosionFrames = {}
local explosionX, explosionY = 0, 0
local explosionFrame = 1
local explosionTimer = 0.05  -- Time between animation frames
local explosionDuration = 0.3  -- Total duration of the explosion animation
local numExplosionFrames = 15
local isExploding = false

local playerExplodeX = 0
local playerExplodeY = 0

-- Movement variables
local diagonalSpeed = player.speed * 0.7071
local rotationSpeed = math.pi * 2  -- 2 * pi radians per second

-- Player Shooting variables
canShoot = true
shootTimer = 0.2 
projectiles = {} 
projectileImage = love.graphics.newImage("/assets/sprites/Ammo/11.png")

-- Enemies Variables
enemies = {}
enemyImage = love.graphics.newImage("/assets/sprites/Others/flying-saucer.png")
enemySpeed = 100
enemySpawnTimer = 2

-- Enemy Shooting variables
canShoot = true
enemyShootTimer = 0.2
enemyProjectiles = {} 
enemyProjectileImage = love.graphics.newImage("/assets/sprites/Ammo/02.png")

local enemiesDefeated = 0
local totalEnemiesToDefeat = 15

-- Scores
local score = 0

-- Colission checker
function checkCollision(x1, y1, radius1, x2, y2, radius2)
    local dx = x1 - x2
    local dy = y1 - y2
    local distance = math.sqrt(dx * dx + dy * dy)
    return distance < radius1 + radius2
end


-- -------------------------------
-- ---------- LOAD PART ----------
-- -------------------------------

function love.load()
    local frameWidth = 192
    local frameHeight = 192

    player.img = love.graphics.newImage("/assets/sprites/Fighter/Idle.png")

    -- Load the sprite sheet (replace 'explosion_sheet.png' with your actual image path)
    explosionImage = love.graphics.newImage("/assets/sprites/Fighter/Destroyed.png")
    
    -- Split the sprite sheet into frames
    explosionFrames = splitSpriteSheet(explosionImage, frameWidth, frameHeight)

    -- Load the boss enemy image
    bossEnemyImage = love.graphics.newImage("assets/sprites/Corvette/Idle.png")
end

function spawnProjectile(x, y, angle)
    local projectile = {
        x = x,
        y = y,
        speed = 500, -- Adjust the speed as needed
        angle = angle -- Angle in radians
    }
    table.insert(projectiles, projectile)
end

function spawnEnemy()
    local x, y, angle

    -- Randomly choose a side to spawn the enemy (top, right, or bottom)
    local side = love.math.random(1, 3)
    if side == 1 then
        x = love.math.random(0, love.graphics.getWidth() - enemyImage:getWidth())
        y = -enemyImage:getHeight()
        angle = math.pi / 2  -- Downward angle
    elseif side == 2 then
        x = love.graphics.getWidth()
        y = love.math.random(0, love.graphics.getHeight() - enemyImage:getHeight())
        angle = math.pi  -- Leftward angle
    else
        x = love.math.random(0, love.graphics.getWidth() - enemyImage:getWidth())
        y = love.graphics.getHeight()
        angle = -math.pi / 2  -- Upward angle
    end

    local enemy = { x = x, y = y, angle = angle, canShoot = true, shootTimer = love.math.random(2, 4), targetAngle = 0 }
    table.insert(enemies, enemy)
end

function spawnBossEnemy()
    -- Create the boss enemy
    local bossEnemy = {
        x = love.graphics.getWidth(),  -- Spawn from the right side
        y = love.math.random(0, love.graphics.getHeight() - bossEnemyImage:getHeight()),
        angle = math.pi,  -- You can set the initial angle as needed
        speed = 150,  -- Adjust the speed as needed
        health = 500,  -- Adjust the boss's health
    }
    table.insert(enemies, bossEnemy)

    -- Update a flag to stop the background when the boss appears
    isBackgroundMoving = false

end

for _, enemy in ipairs(enemies) do
    enemy.canShoot = true
    enemy.shootTimer = love.math.random(2, 4)
    enemy.targetAngle = 0
end

function spawnEnemyProjectile(enemy)
    local x, y = enemy.x, enemy.y
    local dx = player.x - x
    local dy = player.y - y
    local angle = math.atan2(dy, dx)

    local enemyProjectile = {
        x = x,
        y = y,
        speed = 200,  -- Adjust the speed as needed
        angle = angle,
    }
    table.insert(enemyProjectiles, enemyProjectile)
end

function love.keypressed(key)
    if key == "p" then
        if gameState == GameState.PLAYING then
            gameState = GameState.PAUSED
            isPaused = true
        elseif gameState == GameState.PAUSED then
            gameState = GameState.PLAYING
            isPaused = false
        elseif gameState == GameState.GAME_OVER then
            -- Restart game
            ResetGame()  -- You should define a function to reset the game
        end
    end

    -- Handle additional keypress events for the pause menu
    if isPaused then
        if key == "r" then
            -- Resume the game
            gameState = GameState.PLAYING
            isPaused = false

        elseif key == "q" then
            -- Quit the game
            love.event.quit()
        end
    end

    if gameState == GameState.GAME_OVER then
        if key == "return" then
            -- Reset the game when the player presses Enter
            ResetGame()
        elseif key == "q" then
            -- Quit the game
            love.event.quit()
        end

    end

    -- Handle the win state transition
    if gameState == GameState.PLAYER_WINS then
        if key == "return" then
            ResetGame()
        elseif key == "q" then
            -- Quit the game
            love.event.quit()
        end
    end
end

-- Function to split a sprite sheet into frames
function splitSpriteSheet(image, frameWidth, frameHeight)
    local frames = {}
    local imgWidth, imgHeight = image:getDimensions()
    
    for y = 0, imgHeight - frameHeight, frameHeight do
        for x = 0, imgWidth - frameWidth, frameWidth do
            local frame = love.graphics.newQuad(x, y, frameWidth, frameHeight, imgWidth, imgHeight)
            table.insert(frames, frame)
        end
    end

    return frames
end

function ResetGame()
    -- Reset game variables
    gameState = GameState.PLAYING
    playerHealth = maxPlayerHealth
    score = 0
    isExploding = false
    player.x = 200
    player.y = 200

    -- Clear enemies, projectiles, and other variables that need to be reset
    enemies = {}
    enemyProjectiles = {}
    projectiles = {}
end

-- -------------------------------
-- --------- UPDATE PART ---------
-- -------------------------------

function love.update(dt)


    if playerHealth <= 0 and not isExploding then
        isExploding = true
    end

    if isExploding then
        explosionTimer = explosionTimer - dt
        if explosionTimer <= 0 then
            explosionFrame = explosionFrame + 1
            if explosionFrame > numExplosionFrames then
                isExploding = false
                explosionFrame = 1
            end
            explosionTimer = explosionDuration  -- Reset the timer
        end
    end

    if gameState == GameState.GAME_OVER then
        if isPlayerExploding then
            -- Play the explosion animation at the position where the player was
            -- Use playerExplodeX and playerExplodeY for the explosion position
            -- Increment the frame, handle when it's finished, and set isPlayerExploding to false when done
            explosionX = playerExplodeX
            explosionY = playerExplodeY
    
            explosionTimer = explosionTimer - dt
            if explosionTimer <= 0 then
                explosionFrame = explosionFrame + 1
                if explosionFrame > numExplosionFrames then
                    isPlayerExploding = false
                    -- Additional logic after the explosion animation ends
                else
                    explosionTimer = explosionDuration / numExplosionFrames
                end
            end
    end

end

if gameState == GameState.PLAYING then
    -- Update elapsed time
    -- elapsedTime = elapsedTime + dt


    -- Main movements
    if love.keyboard.isDown("d") and player.x < love.graphics.getWidth() then
        player.x = player.x + (player.speed * dt)
    end
    if love.keyboard.isDown("a") and player.x > 0 then
        player.x = player.x - (player.speed * dt)
    end
    if love.keyboard.isDown("s") and player.y < love.graphics.getHeight() then
        player.y = player.y + (player.speed * dt)
    end
    if love.keyboard.isDown("w") and player.y > 0 then
        player.y = player.y - (player.speed * dt)
    end
    
    -- Diagonal movements
    if love.keyboard.isDown("w") and love.keyboard.isDown("d") then
        player.x = player.x + (diagonalSpeed * dt)
        player.y = player.y - (diagonalSpeed * dt)
    end
    if love.keyboard.isDown("w") and love.keyboard.isDown("a") then
        player.x = player.x - (diagonalSpeed * dt)
        player.y = player.y - (diagonalSpeed * dt)
    end
    if love.keyboard.isDown("s") and love.keyboard.isDown("d") then
        player.x = player.x + (diagonalSpeed * dt)
        player.y = player.y + (diagonalSpeed * dt)
    end
    if love.keyboard.isDown("s") and love.keyboard.isDown("a") then
        player.x = player.x - (diagonalSpeed * dt)
        player.y = player.y + (diagonalSpeed * dt)
    end


    local desiredAngle
    if love.keyboard.isDown("right") then
        desiredAngle = 0  -- Right
    elseif love.keyboard.isDown("left") then
        desiredAngle = math.pi  -- Left
    elseif love.keyboard.isDown("down") then
        desiredAngle = math.pi * 0.5  -- Down
    elseif love.keyboard.isDown("up") then
        desiredAngle = -math.pi * 0.5  -- Up
    -- Add the other diagonal directions as needed
    end

    -- Smoothly interpolate the rotation angle
    if desiredAngle then
        local angleDiff = desiredAngle - player.angle
        if angleDiff > math.pi then
            angleDiff = angleDiff - math.pi * 2
        elseif angleDiff < -math.pi then
            angleDiff = angleDiff + math.pi * 2
        end
        player.angle = player.angle + angleDiff * rotationSpeed * dt
    end

    -- Shooting logic
    if love.keyboard.isDown("space") and canShoot then
        -- Calculate the initial position of the projectile (e.g., player.x and player.y)
        spawnProjectile(player.x, player.y, player.angle)
        canShoot = false
    end

    -- Update projectile positions
    for i, projectile in ipairs(projectiles) do
        local dx = math.cos(projectile.angle) * projectile.speed * dt
        local dy = math.sin(projectile.angle) * projectile.speed * dt
        projectile.x = projectile.x + dx
        projectile.y = projectile.y + dy

        -- Remove projectiles that go off-screen
        if projectile.x < 0 or projectile.x > love.graphics.getWidth() or
           projectile.y < 0 or projectile.y > love.graphics.getHeight() then
            table.remove(projectiles, i)
        end
    end

    -- Update the shooting timer
    if not canShoot then
        shootTimer = shootTimer - dt
        if shootTimer <= 0 then
            canShoot = true
            shootTimer = 0.2 -- Reset the timer for the next shot
        end
    end

    -- Spawn enemies
    enemySpawnTimer = enemySpawnTimer - dt
    if enemySpawnTimer <= 0 then
        spawnEnemy()
        enemySpawnTimer = 2  -- Reset the timer for the next enemy spawn
    end

    -- -- Check if it's time to spawn the boss
    -- if elapsedTime >= 10 and not isBossActive then  -- 120 seconds (2 minutes)
    --     spawnBossEnemy()
    --     isBossActive = true
    -- end


    -- Update enemy positions
    for i, enemy in ipairs(enemies) do
        enemy.x = enemy.x - enemySpeed * dt
        if enemy.x + enemyImage:getWidth() < 0 then
            table.remove(enemies, i)
        end
    end

    -- Calculate target angle for each enemy
    for _, enemy in ipairs(enemies) do
        local dx = player.x - enemy.x
        local dy = player.y - enemy.y
        enemy.targetAngle = math.atan2(dy, dx)
    end

    -- Shooting logic for each enemy
    for _, enemy in ipairs(enemies) do
        if enemy.canShoot then
            spawnEnemyProjectile(enemy)
            enemy.canShoot = false
        end

        enemy.shootTimer = enemy.shootTimer - dt
        if enemy.shootTimer <= 0 then
            enemy.canShoot = true
            enemy.shootTimer = love.math.random(1, 3)  -- Randomize the shoot interval
        end
    end

    -- Update enemy projectile positions
    for i, enemyProjectile in ipairs(enemyProjectiles) do
        local dx = math.cos(enemyProjectile.angle) * enemyProjectile.speed * dt
        local dy = math.sin(enemyProjectile.angle) * enemyProjectile.speed * dt
        enemyProjectile.x = enemyProjectile.x + dx
        enemyProjectile.y = enemyProjectile.y + dy

        -- Remove enemy projectiles that go off-screen
        if enemyProjectile.x < 0 or enemyProjectile.x > love.graphics.getWidth() or
           enemyProjectile.y < 0 or enemyProjectile.y > love.graphics.getHeight() then
           table.remove(enemyProjectiles, i)
        end
    end

    -- Background scrolling
    backgroundX = backgroundX - backgroundSpeed * dt
    
    -- If the background has scrolled past its own width, reset its position
    if backgroundX < -background:getWidth() then
        backgroundX = 0
    end

-- Collision detection between player projectiles and enemies
for i = #projectiles, 1, -1 do
    local projectile = projectiles[i]

    for j = #enemies, 1, -1 do
        local enemy = enemies[j]

        -- Calculate the distance between the projectile and enemy
        local dx = enemy.x - projectile.x
        local dy = enemy.y - projectile.y
        local distance = math.sqrt(dx * dx + dy * dy)

        -- If the distance is less than a threshold (e.g., a collision radius), consider it a hit
        local collisionRadius = 30 -- Adjust as needed
        if distance < collisionRadius then
            -- Remove the projectile and enemy
            table.remove(projectiles, i)
            table.remove(enemies, j)

            -- Update the score
            score = score + 1 -- Increase the score by 1
            enemiesDefeated = score
            break -- Break the inner loop after one enemy is hit
        end

        -- Check if the player has won
        if enemiesDefeated >= totalEnemiesToDefeat then
            gameState = GameState.PLAYER_WINS
        end
    end
end

    -- if regularEnemiesDefeated >= 1 and not isBossActive then
    --     -- Spawn the boss enemy
    --     spawnBossEnemy()
    --     isBossActive = true
    -- end

    -- Check for collisions between enemies and player
    for _, enemy in ipairs(enemies) do
        local distance = math.sqrt((player.x - enemy.x) ^ 2 + (player.y - enemy.y) ^ 2)
        local playerRadius = player.img:getWidth() / 20
        local enemyRadius = enemyImage:getWidth() / 20

        if distance < playerRadius + enemyRadius then
            playerHealth = playerHealth - 15
            if playerHealth <= 0 then
                -- Player is defeated or game over logic (you can handle this as needed)
                isExploding = true
            end
        end
    end

    -- Check for collisions between enemy shots and the player
    for i, enemyProjectile in ipairs(enemyProjectiles) do
        local playerRadius = player.img:getWidth() / 20  -- Assuming the player's collision radius is half the player's width
        local x1, y1 = player.x + playerRadius, player.y + playerRadius
        local x2, y2 = enemyProjectile.x, enemyProjectile.y
        local enemyProjectileRadius = enemyProjectileImage:getWidth() / 2

        if checkCollision(x1, y1, playerRadius, x2, y2, enemyProjectileRadius) then
            -- Remove the enemy shot
            table.remove(enemyProjectiles, i)

            -- Reduce player's health (adjust the amount as needed)
            playerHealth = playerHealth - 15

            if playerHealth <= 0 then
                isExploding = true
                gameState = GameState.GAME_OVER
                playerExplodeX = player.x
                playerExplodeY = player.y
            end
        end
    end

    
end

-- end of update part
end



-- -------------------------------
-- ---------- DRAW PART ----------
-- -------------------------------

function love.draw()
    -- Draw the background multiple times to cover the entire viewport
    local viewportWidth = love.graphics.getWidth()
    local backgroundWidth = background:getWidth()
    
    for i = 0, math.ceil(viewportWidth / backgroundWidth) do
        local x = i * backgroundWidth + backgroundX
        love.graphics.draw(background, x, 0)
    end
    

    -- Player shooting
    for _, projectile in ipairs(projectiles) do
        local scale = 0.3
        love.graphics.draw(projectileImage, projectile.x, projectile.y, projectile.angle, scale, scale, projectileImage:getWidth() / 2, projectileImage:getHeight() / 2)
    end

    -- Draw enemies
    for _, enemy in ipairs(enemies) do
        local scale = 0.4
        love.graphics.draw(enemyImage, enemy.x, enemy.y, enemy.targetAngle, scale, scale, enemyImage:getWidth() / 2, enemyImage:getHeight() / 2)
    end

    -- Draw enemy projectiles
    for _, enemy in ipairs(enemies) do
        for _, enemyProjectile in ipairs(enemyProjectiles) do
            local scale = 0.3  -- Adjust the scale as needed
            love.graphics.draw(enemyProjectileImage, enemyProjectile.x, enemyProjectile.y, enemyProjectile.angle, scale, scale, enemyProjectileImage:getWidth() / 2, enemyProjectileImage:getHeight() / 2)
        end
    end

    -- Display the score
    local scoreText = "Score: " .. score
    local scoreX = 10  -- X-coordinate for the score
    local scoreY = love.graphics.getHeight() - 30  -- Y-coordinate for the score (adjust as needed)
    love.graphics.print(scoreText, scoreX, scoreY, 0, 2, 2)  -- You can adjust the scale (last two arguments) as needed

        -- Draw the health bar
        local healthBarWidth = 150  -- Adjust the width as needed
        local healthBarHeight = 20  -- Adjust the height as needed
        local healthBarX = 10  -- Adjust the X position as needed
        local healthBarY = 40  -- Adjust the Y position as needed
    
    -- Draw the health bar background
    love.graphics.setColor(255, 0, 0)  -- Red color
    love.graphics.rectangle("fill", 10, 10, maxPlayerHealth * 2, 20)  -- Adjust size and position as needed

    -- Reset color to white
    love.graphics.setColor(255, 255, 255)

    -- Draw the current health status
    love.graphics.setColor(0, 255, 0)  -- Green color
    love.graphics.rectangle("fill", 10, 10, playerHealth * 2, 20)  -- Adjust size and position as needed

    -- Reset color to white again
    love.graphics.setColor(255, 255, 255)

    if isBossActive then
        -- Draw the boss
        love.graphics.draw(bossEnemyImage, bossEnemy.x, bossEnemy.y, bossEnemy.angle, scale, scale, bossEnemyImage:getWidth() / 2, bossEnemyImage:getHeight() / 2)
    end


    if isExploding then
        love.graphics.draw(explosionImage, explosionFrames[explosionFrame], explosionX, explosionY)
        explosionX = player.x
        explosionY = player.y
    end

    if gameState == GameState.GAME_OVER then
        if isPlayerExploding then
            love.graphics.draw(explosionImage, explosionFrames[explosionFrame], explosionX, explosionY)
        else
            love.graphics.print("Game Over", love.graphics.getWidth() / 2 - 60, love.graphics.getHeight() / 2 - 20)
            love.graphics.print("Press 'Enter' to Play Again", love.graphics.getWidth() / 2 - 100, love.graphics.getHeight() / 2 + 20)
        end
    else
        -- Draw the player when the game is not over
        love.graphics.draw(player.img, player.x, player.y, player.angle, 1, 1, player.img:getWidth() / 2, player.img:getHeight() / 2)
    end

    if isPaused then
        -- Render a semi-transparent overlay for the pause menu
        love.graphics.setColor(0, 0, 0, 128) -- Black with 50% opacity
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

        -- Render the pause menu options
        love.graphics.setColor(255, 255, 255) -- White
        love.graphics.print("PAUSED", love.graphics.getWidth() / 2 - 40, love.graphics.getHeight() / 2 - 20)
        love.graphics.print("Press 'R' to Resume", love.graphics.getWidth() / 2 - 80, love.graphics.getHeight() / 2 + 10)
        love.graphics.print("Press 'Q' to Quit", love.graphics.getWidth() / 2 - 60, love.graphics.getHeight() / 2 + 40)
    end

    if gameState == GameState.PLAYER_WINS then
        love.graphics.print("Congratulations! You win!", love.graphics.getWidth() / 2 - 120, love.graphics.getHeight() / 2 - 20)
        love.graphics.print("Press 'Enter' to Play Again", love.graphics.getWidth() / 2 - 100, love.graphics.getHeight() / 2 + 20)
    end

end