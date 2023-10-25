player = {x = 200, y = 200, speed = 250, img = nil}

mayFire = true
tiempoDisparoMax = 0.2
timeDisparo = tiempoDisparoMax

balasImg = nil
balas = {}



function love.load(arg)
    player.img = love.graphics.newImage("/sprites/Fighter/Idle.png")
    balassImg = love.graphics.newImage("/sprites/Ammo/11.png")
end


function love.update(dt)
    if love.keyboard.isDown("right") then
        player.x = player.x + (player.speed * dt)
        end
        if love.keyboard.isDown("left") then
        player.x = player.x - (player.speed * dt)
        end
        if love.keyboard.isDown("down") then
        player.y = player.y + (player.speed * dt)
        end
        if love.keyboard.isDown("up") then
        player.y = player.y - (player.speed * dt)
        end
        
        if love.keyboard.isDown("up") and love.keyboard.isDown("right") then
        player.x = player.x + (math.sqrt(player.x + player.y) * dt)
        player.y = player.y - (math.sqrt(player.x + player.y) * dt)
        end
    end

    timeDisparo = timeDisparo - (1*dt)
    if timeDisparo < 0 then
        mayFire = true
    end

    if love.keyboard.isDown("space") and mayFire then
        newShot = {
            x = player.x + (player.img:getWidth()/2),
            y = player.y, img = balasImg
        }

        table.insert(balas, newShot)
        mayFire = false
        timeDisparo = tiempoDisparoMax

    end

function love.draw(dt)
    love.graphics.draw(player.img, player.x, player.y)

    for i, bala in ipairs(bala) do
        bala.y = bala.y - (350 * dt)

        if bala.y < 0 then
            table.remove(bala, i)
        end
    end
end