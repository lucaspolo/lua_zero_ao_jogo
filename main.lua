LARGURA_TELA = 320
ALTURA_TELA = 480
MAX_METEOROS = 12

METEORO_LARGURA = 50
METEORO_ALTURA = 44

PONTUACAO = 0

OBJETIVO = 10

aviao_14bis = {
    src = "imagens/14bis.png",
    largura = 55,
    altura = 63,
    x = (LARGURA_TELA - 64) / 2,
    y = ALTURA_TELA - 64,
    tiros = {}
}

meteoros = {}

function love.load()
    math.randomseed(os.time())
    love.window.setMode(LARGURA_TELA, ALTURA_TELA, {resizable = false})
    love.window.setTitle("14Bis vs Meteoros")

    background = love.graphics.newImage("imagens/background.png")
    aviao_14bis.imagem = love.graphics.newImage(aviao_14bis.src)
    meteoro_img = love.graphics.newImage("imagens/meteoro.png")
    tiro_img = love.graphics.newImage("imagens/tiro.png")
    gameover_img = love.graphics.newImage("imagens/gameover.png")
    vencedor_img = love.graphics.newImage("imagens/vencedor.png")

    musica_ambiente = love.audio.newSource("audios/ambiente.wav", "static")
    musica_ambiente:setLooping(true)
    musica_ambiente:play()
    destruicao = love.audio.newSource("audios/destruicao.wav", "static")
    game_over = love.audio.newSource("audios/game_over.wav", "static")
    disparo = love.audio.newSource("audios/disparo.wav", "static")
    vencedor = love.audio.newSource("audios/winner.wav", "static")
end


function temColisao(x1, y1, l1, a1, x2, y2, l2, a2)
    return x2 < x1 + l1 and
        x1 < x2 + l2 and
        y1 < y2 + a2 and
        y2 < y1 + a1
end

function criarMeteoro()
    meteoro = {
        x = math.random(LARGURA_TELA),
        y = -METEORO_ALTURA,
        velocidade = math.random(3),
        deslocamento_horizontal = math.random(-1, 1)
    }

    table.insert(meteoros, meteoro)
end

function move14bis()
    if love.keyboard.isDown('up') then
        aviao_14bis.y = aviao_14bis.y - 1
    end
    if love.keyboard.isDown('down') then
        aviao_14bis.y = aviao_14bis.y + 1
    end
    if love.keyboard.isDown('right') then
        aviao_14bis.x = aviao_14bis.x + 1
    end
    if love.keyboard.isDown('left') then
        aviao_14bis.x = aviao_14bis.x - 1
    end

    if aviao_14bis.x + aviao_14bis.largura > LARGURA_TELA then
        aviao_14bis.x = aviao_14bis.x - 1
    end
    if aviao_14bis.x < 0 then
        aviao_14bis.x = aviao_14bis.x + 1
    end

    if aviao_14bis.y + aviao_14bis.altura > ALTURA_TELA then
        aviao_14bis.y = aviao_14bis.y - 1
    end
    if aviao_14bis.y < 0 then
        aviao_14bis.y = aviao_14bis.y + 1
    end
end

function moveMeteoros() 
    for k, meteoro in pairs(meteoros) do
        meteoro.y = meteoro.y + meteoro.velocidade
        meteoro.x = meteoro.x + meteoro.deslocamento_horizontal
    end
end

function removeMeteoros()
    for i = #meteoros, 1, -1 do
        if meteoros[i].y > ALTURA_TELA then
            table.remove(meteoros, i)
        end

        if meteoros[i].x > LARGURA_TELA or meteoros[i].x + METEORO_LARGURA < 0 then
            table.remove(meteoros, i)
        end
    end
end

function destroiAviao()
    destruicao:play()

    aviao_14bis.src = "imagens/explosao_nave.png"
    aviao_14bis.imagem = love.graphics.newImage(aviao_14bis.src)
    aviao_14bis.largura = 67
    aviao_14bis.altura = 77
end

function trocaMusicaDeFundo()
    musica_ambiente:stop()
    game_over:play()
end

function verificarColisoesComAviao()
    for k, meteoro in pairs(meteoros) do
        if temColisao(
            meteoro.x, meteoro.y, METEORO_ALTURA, METEORO_LARGURA, 
            aviao_14bis.x, aviao_14bis.y, aviao_14bis.largura, aviao_14bis.altura
        ) then
            trocaMusicaDeFundo()
            destroiAviao()
            FIM_JOGO = true
        end
    end
end

function verificarColisoesComTiros()
    for i = #aviao_14bis.tiros, 1, -1 do
        for j = #meteoros, 1, -1 do
            if temColisao(
                meteoros[j].x, meteoros[j].y, METEORO_ALTURA, METEORO_LARGURA,
                aviao_14bis.tiros[i].x, aviao_14bis.tiros[i].y, aviao_14bis.tiros[i].largura, aviao_14bis.tiros[i].altura
            ) then
                table.remove(aviao_14bis.tiros, i)
                table.remove(meteoros, j)
                PONTUACAO = PONTUACAO + 1
                break
            end
        end
    end    
end

function verificarObjetivo()
    if PONTUACAO >= OBJETIVO then
        VENCEDOR = true
        musica_ambiente:stop()
        vencedor:play()
    end
end

function verificarColisoes()
    verificarColisoesComAviao()
    verificarColisoesComTiros()
end

function moveTiros()
    for i=#aviao_14bis.tiros, 1, -1 do
        if aviao_14bis.tiros[i].y > 0 then
            aviao_14bis.tiros[i].y = aviao_14bis.tiros[i].y - aviao_14bis.tiros[i].velocidade
        else
            table.remove(aviao_14bis.tiros, i)
        end
    end
end

function love.update(dt)
    if not FIM_JOGO and not VENCEDOR and not PAUSED then
        if love.keyboard.isDown('up', 'left', 'down', 'right') then
            move14bis()
        end

        removeMeteoros()
        
        if #meteoros < MAX_METEOROS then
            criarMeteoro()
        end
        moveMeteoros()
        moveTiros()
        verificarColisoes()
        verificarObjetivo()
    end
end

function atirar()
    disparo:play()

    local tiro = {
        x = aviao_14bis.x + aviao_14bis.largura / 2,
        y = aviao_14bis.y,
        largura = 16,
        altura = 16,
        velocidade = 2
    }

    table.insert(aviao_14bis.tiros, tiro)
end

function love.keypressed(tecla)
    if tecla == "escape" then
        love.event.quit()
    elseif tecla == "space" then
        atirar()
    end

    if tecla == "p" then
    	PAUSED = not PAUSED
   	end
end

function love.draw()
    love.graphics.draw(background, 0, 0)
    love.graphics.draw(
        aviao_14bis.imagem, 
        aviao_14bis.x,
        aviao_14bis.y
    )

    love.graphics.print("Meteoros restantes: "..OBJETIVO - PONTUACAO)

    for k, meteoro in pairs(meteoros) do
        love.graphics.draw(meteoro_img, meteoro.x, meteoro.y)
    end

    for k, tiro in pairs(aviao_14bis.tiros) do
        love.graphics.draw(tiro_img, tiro.x, tiro.y)
    end

    if FIM_JOGO then
        love.graphics.draw(
            gameover_img, 
            LARGURA_TELA / 2 - gameover_img:getWidth() / 2, 
            ALTURA_TELA / 2 - gameover_img:getHeight() /2
        )
    end

    if VENCEDOR then
        love.graphics.draw(
            vencedor_img, 
            LARGURA_TELA / 2 - vencedor_img:getWidth() / 2, 
            ALTURA_TELA / 2 - vencedor_img:getHeight() /2
        )
    end

    if PAUSED then
    	love.graphics.setColor(0.4, 0.4, 0.4, 0.5)
    	love.graphics.rectangle("fill", 0, 0, LARGURA_TELA, ALTURA_TELA)
    	love.graphics.setColor(1, 1, 1, 1)
    end
end
