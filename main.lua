#!/usr/bin/env love
-- PHOTON
-- 0.4
-- Editor (love2d)

-- main.lua

-- MIT License
-- Copyright (c) 2019 Alexander Veledzimovich veledz@gmail.com

-- Permission is hereby granted, free of charge, to any person obtaining a
-- copy of this software and associated documentation files (the "Software"),
-- to deal in the Software without restriction, including without limitation
-- the rights to use, copy, modify, merge, publish, distribute, sublicense,
-- and/or sell copies of the Software, and to permit persons to whom the
-- Software is furnished to do so, subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
-- FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
-- DEALINGS IN THE SOFTWARE.

-- lua<5.3
io.stdout:setvbuf('no')
local unpack = table.unpack or unpack
local utf8 = require('utf8')

local nuklear = require('nuklear')
local fl = require('lib/lovfl')
local imd = require('lib/lovimd')

local set = require('editor/set')
local ui = require('editor/ui')

-- 0.5
-- move code
-- pause stop start reset count

-- many systems pick different and emit or edit them
-- add info about systems (buf x,y,count)
-- separate code generate func

-- generate update function for created particle
-- copy or not copy code

-- 0.6
-- add colors
-- rollback to default state
-- import photon

local PS = {particles={}, count = 0,systems = 0,drag=false}
PS.forms={'circle','ellipse','triangle','rectangle','hexagon','star'}
PS.imgdata={}
PS.hotset={value=false}
PS.codeState=false
PS.code={value=''}
PS.name=''
PS.set={
        x=set.VIEWWID/2,y=set.VIEWHEI/2,
        mode={value='top'},
        buffer={value=set.PBUFFER/2},
        emit={value=1024},lifetime={value=-1},
        loadpath={value=''},imgdata={value='none'},
        qCols={value=1},qRows={value=1},
        form={value='star'},
        wid={value=196},hei={value=8},offsetX={value=98},offsetY={value=4},
        color={{0.5,0.5,0.5,0.5},{1.0,1.0,1,0.5},{1.0,1.0,1.0,0.0}},
        rate={value=512},
        areaForm={value='borderellipse'},areaX={value=96},areaY={value=96},
        areaAng={value=0},areaDir={value=true},
        timeMin={value=0.5},timeMax={value=3},
        size1={value=0},size2={value=0.2},size3={value=0.4},
        size4={value=0.6},size5={value=0.8},size6={value=1},
        size7={value=1},size8={value=1},
        sizeVar={value=1},
        speedMin={value=8},speedMax={value=32},
        dampMin={value=0.5},dampMax={value=1},
        accXMin={value=0},accXMax={value=0},
        accYMin={value=0},accYMax={value=0},
        radAccMin={value=0},radAccMax={value=0},
        tanAccMin={value=0},tanAccMax={value=8},
        dir={value=0},spread={value=1},
        spinMin={value=0},spinMax={value=0},spinVar={value=1},
        rotateMin={value=0},rotateMax={value=0},
        relative={value=true},
    }

function PS.generate()
    PS.setName()
    local clr = {}
    for i=1, #PS.set.color do
        for j=1, #PS.set.color[i] do clr[#clr+1] = PS.set.color[i][j] end
    end

    local code = [[
-- ]]..set.VER..' '..set.APPNAME..[[ Editor (love2d)

local unpack = table.unpack or unpack
local quads

local function photon()
    local data = love.image.newImageData(']]..set.DEFPATH..'/'..PS.pathImd()..[[')
    local tx = love.graphics.newImage(data)
    local ph = love.graphics.newParticleSystem(tx,]]..PS.set.buffer.value..[[)
    ph:setEmitterLifetime(]]..PS.set.lifetime.value..[[)
    ph:setInsertMode(']]..PS.set.mode.value..[[')
    if ]]..tostring(PS.set.imgdata.value~='none')..[[ then
        local q = quads(data,]]..PS.set.qCols.value..[[,]]..PS.set.qRows.value..[[)
        ph:setQuads(unpack(q))
    end
    ph:setOffset(]]..PS.set.offsetX.value..[[,]]..PS.set.offsetY.value..[[)
    ph:setColors(]]..table.concat(clr,',')..[[)
    ph:setEmissionRate(]]..PS.set.rate.value..[[)
    ph:setEmissionArea(']]..PS.set.areaForm.value..[[',]]..PS.set.areaX.value..[[,]]..PS.set.areaY.value..[[,]]..PS.set.areaAng.value..[[,]]..tostring(PS.set.areaDir.value)..[[)
    ph:setParticleLifetime(]]..PS.set.timeMin.value..[[,]]..PS.set.timeMax.value..[[)
    ph:setSizes(]]..PS.set.size1.value..[[,]]..PS.set.size2.value..[[,]]..PS.set.size3.value..[[,]]..PS.set.size4.value..[[,]]..PS.set.size5.value..[[,]]..PS.set.size6.value..[[,]]..PS.set.size7.value..[[,]]..PS.set.size8.value..[[)
    ph:setSizeVariation(]]..PS.set.sizeVar.value..[[)

    ph:setSpeed(]]..PS.set.speedMin.value..[[,]]..PS.set.speedMax.value..[[)
    ph:setLinearAcceleration(]]..PS.set.accXMin.value..[[,]]..PS.set.accYMin.value..[[,]]..PS.set.accXMax.value..[[,]]..PS.set.accYMax.value..[[)
    ph:setRadialAcceleration(]]..PS.set.radAccMin.value..[[,]]..PS.set.radAccMax.value..[[)
    ph:setTangentialAcceleration(]]..PS.set.tanAccMin.value..[[,]]..PS.set.tanAccMax.value..[[)
    ph:setLinearDamping(]]..PS.set.dampMin.value..[[,]]..PS.set.dampMax.value..[[)
    ph:setDirection(]]..PS.set.dir.value..[[)
    ph:setSpread(]]..PS.set.spread.value..[[)
    ph:setSpin(]]..PS.set.spinMin.value..[[,]]..PS.set.spinMax.value..[[)
    ph:setSpinVariation(]]..PS.set.spinVar.value..[[)
    ph:setRotation(]]..PS.set.rotateMin.value..[[,]]..PS.set.rotateMax.value..[[)
    ph:setRelativeRotation(]]..tostring(PS.set.relative.value)..[[)
    return ph
end

function quads(imgdata,numx,numy)
    local q = {}
    local iw, ih = imgdata:getDimensions()
    local qw, qh = iw/numx, ih/numy
    for y=0,numy-1 do
        for x=0,numx-1 do
            q[#q+1]=love.graphics.newQuad(
                    qw*x,qh*y,qw,qh,iw,ih)
        end
    end
    return q
end
return photon()
]]
    return code
end

function PS.round(val,pos) pos = pos or 2 return val-val%(1/10^pos) end

function PS.loadImd()
    for k,v in pairs(fl.loadPath(PS.set.loadpath.value,unpack(set.IMGEXT))) do
        PS.imgdata[k]=love.image.newImageData(v)
        PS.set.imgdata.value=k
    end
end

function PS.saveImd()
    local imgname = PS.name..'/'..PS.pathImd()
    PS.getImageData():encode('png',imgname)
end

function PS.removeImd()
    fl.removeAll(set.TMPDIR,true)
end

function PS.pathImd()
    return PS.name..'.png'
end

function PS.setName()
    if PS.set.imgdata.value=='none' then
        PS.name = PS.set.form.value..os.time()
    else
        PS.name = PS.set.imgdata.value..os.time()
    end
end

function PS.export()
    if #PS.code.value>0 then
        love.filesystem.createDirectory(PS.name)
        local phtname = PS.name..'/'..PS.name..'.'..set.PEXT
        PS.saveImd()
        fl.saveLove(phtname,PS.code.value,true)
    end
end

function PS.import()

end

function PS.drop(file)
    local path = fl.copyLove(file,set.TMPDIR)
    PS.set.loadpath.value = set.TMPDIR..'/'..fl.name(path)
    PS.loadImd()
end

function PS.buffer()
    for particle in pairs(PS.particles) do
        particle:setBufferSize(PS.set.buffer.value)
    end
end

function PS.emit()
    for particle in pairs(PS.particles) do
        particle:emit(PS.set.emit.value)
    end
end

function PS.lifetime()
    for particle in pairs(PS.particles) do
        particle:setEmitterLifetime(PS.set.lifetime.value)
        particle:reset()
        particle:start()
    end
end

function PS.clear()
    for particle in pairs(PS.particles) do
        particle:reset()
        PS.particles[particle]=nil
    end
end

function PS.setup(particle)
    particle:setInsertMode(PS.set.mode.value)

    particle:setTexture(love.graphics.newImage(PS.getImageData()))
    if PS.set.imgdata~='none' then
        particle:setQuads(PS.getQuads())
    end

    particle:setOffset(PS.set.offsetX.value,PS.set.offsetY.value)
    local clr = {}
    for i=1, #PS.set.color do
        for j=1, #PS.set.color[i] do clr[#clr+1] = PS.set.color[i][j] end
    end
    particle:setColors(unpack(clr))

    particle:setEmissionRate(PS.set.rate.value)
    particle:setEmissionArea(
            PS.set.areaForm.value,
            PS.set.areaX.value,PS.set.areaY.value,
            PS.set.areaAng.value,PS.set.areaDir.value
        )

    particle:setSizes(PS.set.size1.value,PS.set.size2.value,PS.set.size3.value,
                PS.set.size4.value,PS.set.size5.value,PS.set.size6.
                value,PS.set.size7.value,PS.set.size8.value)
    particle:setSizeVariation(PS.set.sizeVar.value)

    particle:setParticleLifetime(PS.set.timeMin.value,
                                 PS.set.timeMax.value)

    particle:setSpeed(PS.set.speedMin.value,PS.set.speedMax.value)
    particle:setLinearAcceleration(PS.set.accXMin.value,
                                   PS.set.accYMin.value,
                                   PS.set.accXMax.value,
                                   PS.set.accYMax.value)
    particle:setRadialAcceleration(PS.set.radAccMin.value,
                                   PS.set.radAccMax.value)
    particle:setTangentialAcceleration(PS.set.tanAccMin.value,
                                        PS.set.tanAccMax.value)
    particle:setLinearDamping(PS.set.dampMin.value,PS.set.dampMax.value)

    particle:setDirection(PS.set.dir.value)
    particle:setSpread(PS.set.spread.value)

    particle:setSpin(PS.set.spinMin.value,
                     PS.set.spinMax.value)
    particle:setSpinVariation(PS.set.spinVar.value)

    particle:setRotation(PS.set.rotateMin.value,
                         PS.set.rotateMax.value)

    particle:setRelativeRotation(PS.set.relative.value)

    PS.code.value=PS.generate()
end

function PS.getQuads()
    local imageData = PS.imgdata[PS.set.imgdata.value]
    if not imageData then return end
    local sx, sy = imageData:getDimensions()
    return imd.quads(imageData,
            sx/PS.set.qCols.value, sy/PS.set.qRows.value,
            PS.set.qCols.value,PS.set.qRows.value)
end

function PS.getImageData()
    local texture
    local imageData = PS.imgdata[PS.set.imgdata.value]
    if imageData then
        texture = imageData
    else
        texture = imd.form(PS.set.form.value,{1,1,1,1},
                PS.set.wid.value,PS.set.hei.value)
    end
    return texture
end

function PS.new()
    local tx = love.graphics.newImage(PS.getImageData())
    local particle = love.graphics.newParticleSystem(tx, PS.set.buffer.value)
    particle:setPosition(PS.set.x,PS.set.y)
    particle:setEmitterLifetime(PS.set.lifetime.value)

    PS.setup(particle)
    PS.particles={}
    PS.particles[particle]=particle
end

local nk
function love.load()
    if arg[1] then print(set.VER, set.APPNAME, 'Editor (love2d)', arg[1]) end
    love.window.setPosition(0,0)
    love.graphics.setBackgroundColor(set.BGCLR)
    love.keyboard.setKeyRepeat(true)
    love.filesystem.createDirectory(set.TMPDIR)
    nk=nuklear.newUI()
end

function love.update(dt)
    local title = string.format('%s %s fps %.2d systems %d particles %d',
                            set.APPNAME, set.VER, love.timer.getFPS(),
                            PS.systems, PS.count)
    love.window.setTitle(title)

    ui.editor(nk,PS)

    PS.count=0
    PS.systems=0
    for particle in pairs(PS.particles) do
        if PS.hotset.value then
            PS.setup(particle)
        end

        particle:update(dt)
        PS.systems=PS.systems+1
        PS.count=PS.count+particle:getCount()
    end
end

function love.draw()
    love.graphics.rectangle('line',
            PS.set.x-set.MARKRAD,PS.set.y-set.MARKRAD,
            set.MARKRAD*2,set.MARKRAD*2)

    for particle in pairs(PS.particles) do
        love.graphics.draw(particle)
        local x,y=particle:getPosition()
        love.graphics.circle('line',x,y,set.MARKRAD)
    end
    nk:draw()
end

function love.filedropped(file)
    PS.drop(file)
end

function love.keypressed(key, unicode, isrepeat)
    nk:keypressed(key, unicode, isrepeat)
end

function love.keyreleased(key, unicode)
    nk:keyreleased(key, unicode)
end

function love.mousepressed(x, y, button, istouch)
    nk:mousepressed(x, y, button, istouch)
    if button==1 then
        for particle in pairs(PS.particles) do
            local px, py = particle:getPosition()
            if ((px-x)^2 + (py-y)^2) < set.MARKRAD^2 and not PS.drag then
                PS.drag = true
            end
        end
    end
    if button==2 then
        if PS.codeState=='active' then
            love.system.setClipboardText(PS.code.value)
        end
    end
end

function love.mousereleased(x, y, button, istouch)
    nk:mousereleased(x, y, button, istouch)
    if button==1 then
        PS.drag = false
    end
end

function love.mousemoved(x, y, dx, dy, istouch)
    nk:mousemoved(x, y, dx, dy, istouch)
    if PS.drag then
        for particle in pairs(PS.particles) do
            particle:moveTo(x,y)
        end
    end
end

function love.wheelmoved(x, y) nk:wheelmoved(x, y) end

function love.textinput(text) nk:textinput(text) end

function love.quit()
    PS.removeImd()
    print(set.VER, set.APPNAME, 'Editor (love2d)', 'quit')
end
