WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 200

WINNING_SCORE = 3

Class = require "class"
push = require "push" --require the library

require 'Ball'
require 'Paddle'

function love.load()

    math.randomseed(os.time())

    love.graphics.setDefaultFilter('nearest', 'nearest')

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        vsync = true,
        resizable = true
    })

    love.window.setTitle("Pong!")

    smallFont = love.graphics.newFont('font.ttf', 8)
    scoreFont = love.graphics.newFont('font.ttf', 32)
    victoryFont = love.graphics.newFont('font.ttf', 24)

    sounds = {
        ['paddle_hit'] = love.audio.newSource('paddle_hit.wav', 'static'),
        ['point_scored'] = love.audio.newSource('point_scored.wav', 'static'),
        ['wall_hit'] = love.audio.newSource('wall_hit.wav', 'static')
    }

    player1score = 0
    player2score = 0

    servingPlayer = math.random(2) == 1 and 1 or 2

    winningPlayer = 0

    paddle1 = Paddle(5, 20, 5, 20)
    paddle2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5, 20)
    ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 5, 5)

    ball.dx = servingPlayer == 1 and 100 or -100

    gameState = 'start'
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.update(dt)

    if gameState == 'play' then

        if ball.x <= 0 then
            sounds['point_scored']:play()
            player2score = player2score + 1
            servingPlayer = 1
            if player2score >= 3 then
                gameState = 'victory'
                winningPlayer = 2
            else
                gameState = 'serve'
                ball:reset()
            end
        end

        if ball.x >= VIRTUAL_WIDTH - 4 then
            sounds['point_scored']:play()
            player1score = player1score + 1
            servingPlayer = 2
            if player1score >= 3 then
                gameState = 'victory'
                winningPlayer = 1
            else
                gameState = 'serve'
                ball:reset()
            end
        end

        if ball:collides(paddle1) then
            ball.dx = -ball.dx * 1.03
            ball.x = paddle1.x + 5

            sounds['paddle_hit']:play()

            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end

        end

        if ball:collides(paddle2) then
            ball.dx = -ball.dx * 1.03
            ball.x = paddle2.x - 4

            sounds['paddle_hit']:play()

            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end
        end

        if ball.y <= 0 then
            ball.y = 0
            ball.dy = -ball.dy
            sounds['wall_hit']:play()
        end


        if ball.y >= VIRTUAL_HEIGHT - 4 then
            ball.y = VIRTUAL_HEIGHT - 4
            ball.dy = -ball.dy
            sounds['wall_hit']:play()
        end

        paddle1:update(dt)
        paddle2:update(dt)

        if ball.y < paddle1.y + 10 then
            paddle1.dy = -PADDLE_SPEED / 2
        elseif ball.y > paddle1.y + 10 then
            paddle1.dy = PADDLE_SPEED / 2
        else
            paddle1.dy = 0
        end

        if love.keyboard.isDown('up') then
            paddle2.dy = -PADDLE_SPEED
        elseif love.keyboard.isDown('down') then
            paddle2.dy = PADDLE_SPEED
        else
            paddle2.dy = 0
        end

        ball:update(dt)
    end
end

function love.keypressed(key)

    -- quit game
    if key == 'escape' then
        love.event.quit()

    -- gameState Controller
    elseif key == 'enter' or key == 'return' then
        if gameState == 'start' then
            gameState = 'serve'
        elseif gameState == "victory" then
            gameState = 'start'
            player1score = 0
            player2score = 0
            ball:reset()
        elseif gameState == "serve" then
            ball.dx = servingPlayer == 1 and 100 or -100
            gameState = 'play'
        end
    end
end

function love.draw()
    push:apply('start')

    love.graphics.clear(
        40 / 255, 
        45 / 255,
        52 / 255, 
        255 / 255
    )

    paddle1:render()
    paddle2:render()

    ball:render()

    love.graphics.setFont(smallFont)
    
    if gameState == 'start' then
        love.graphics.setFont(smallFont)
        love.graphics.printf('Welcome to Pong!', 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to Begin!', 0, 20, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'serve' then
        love.graphics.setFont(smallFont)
        love.graphics.printf('Player '.. tostring(servingPlayer) .. "'s turn!", 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to Serve!', 0, 20, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'victory' then
        love.graphics.setFont(victoryFont)
        love.graphics.printf('Player '.. tostring(winningPlayer) .. " wins!", 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf('Press Enter to Restart!', 0, 42, VIRTUAL_WIDTH, 'center')
    end

    love.graphics.setFont(scoreFont)
    love.graphics.print(
        player1score, 
        VIRTUAL_WIDTH / 2 - 50,
        VIRTUAL_HEIGHT / 3
    )
    love.graphics.print(
        player2score, 
        VIRTUAL_WIDTH / 2 + 30,
        VIRTUAL_HEIGHT / 3
    )

    displayFPS()

    push:apply('end')
end

function displayFPS()
    love.graphics.setColor(0, 1, 0, 1)
    love.graphics.setFont(smallFont)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 40 ,20)
    love.graphics.setColor(1, 1, 1, 1)
end