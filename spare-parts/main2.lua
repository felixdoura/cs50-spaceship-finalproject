player = {x = 200, y = 600, speed = 250, img = nil}


function love.load()
    -- mySquare = {}
    -- mySquare.x = 100
    -- mySquare.y = 100
    -- mySquare.height = 200
    -- mySquare.width = 200
    
    playerShipImg = love.graphics.newImage("/sprites/Fighter/Idle.png")
    
    playerx = 300
    playery = 400
    playerspeed = 300
    
    angle = 180
    end
    
    function love.update(dt)
    -- if love.keyboard.isDown('w') then
    -- mySquare.y = mySquare.y - 1
    -- elseif love.keyboard.isDown('s') then
    -- mySquare.y = mySquare.y + 1
    -- elseif love.keyboard.isDown('a') then
    -- mySquare.x = mySquare.x - 1
    -- elseif love.keyboard.isDown('d') then
    -- mySquare.x = mySquare.x + 1
    
    if love.keyboard.isDown("right") then
    playerx = playerx + (playerspeed * dt)
    end
    if love.keyboard.isDown("left") then
    playerx = playerx - (playerspeed * dt)
    end
    if love.keyboard.isDown("down") then
    playery = playery + (playerspeed * dt)
    end
    if love.keyboard.isDown("up") then
    playery = playery - (playerspeed * dt)
    end
    
    if love.keyboard.isDown("up") and love.keyboard.isDown("right") then
    playerx = playerx + (math.sqrt(playerx + playery) * dt)
    playery = playery - (math.sqrt(playerx + playery) * dt)
    end
    end
    
    function love.draw()
    -- love.graphics.rectangle("line", mySquare.x, mySquare.y, mySquare.width, mySquare.height)
    
    love.graphics.draw(playerShipImg, playerx, playery)
    end