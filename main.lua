#!/usr/bin/env love
-- PHOTON
-- 0.3
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

-- 0.4
-- mark setup with color or hot reload sign
-- separate ui
-- separate code generate func
-- pause stop start reset count
-- check min max

-- many systems pick different and emit or edit them
-- add info about systems (buf x,y,count)

-- generate update function for created particle
-- copy or not copy code


-- 0.6
-- default state
-- reset sliders
-- import photon

-- 1.0
-- crossplatform

local PS = {particles={}, count = 0,systems = 0,drag=false}
PS.forms={'circle','ellipse','triangle','rectangle','hexagon','star'}
PS.imgdata={}
PS.hotset={value=false}
PS.codeState=false
PS.photonname = nil
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
        sizeStart={value=0.5},sizeFinal={value=1},sizeVar={value=1},
        timeMin={value=0.5},timeMax={value=3},
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
        code={value=''}
    }

function PS.generate()
    PS.photonname = PS.photonName()
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
    ph:setSizes(]]..PS.set.sizeStart.value..[[,]]..PS.set.sizeFinal.value..[[)
    ph:setSizeVariation(]]..PS.set.sizeVar.value..[[)
    ph:setParticleLifetime(]]..PS.set.timeMin.value..[[,]]..PS.set.timeMax.value..[[)
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
    local imgname = PS.photonname..'/'..PS.pathImd()
    PS.getImageData():encode('png',imgname)
end

function PS.pathImd()
    return PS.photonname..'.png'
end

function PS.photonName()
    if PS.set.imgdata.value=='none' then
        return PS.set.form.value..os.time()
    else
        return PS.set.imgdata.value..os.time()
    end
end

function PS.export()
    if #PS.set.code.value>0 then
        love.filesystem.createDirectory(PS.photonname)
        local phtname = PS.photonname..'/'..PS.photonname..'.'..set.PEXT
        PS.saveImd()
        fl.saveLove(phtname,PS.set.code.value,true)
    end
end

function PS.import()

end

function PS.drop(file)
    local path = fl.copyLove(file,set.TMPDIR)
    PS.set.loadpath.value = set.TMPDIR..'/'..fl.name(path)
    PS.loadImd()
end

function PS.clearDir()
    fl.removeAll(set.TMPDIR,true)
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

function PS.clearParticles()
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

    particle:setSizes(PS.set.sizeStart.value,PS.set.sizeFinal.value)
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

    PS.set.code.value=PS.generate()
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

    nk:frameBegin()
    if nk:windowBegin('Code', 0, set.MIDHEI, set.CODEWID, set.CODEHEI,
            'border', 'title', 'movable','minimizable','scrollbar') then
        local _,_,_,hei = nk:windowGetContentRegion()
        nk:layoutRow('dynamic', hei-8, 1)
        if nk:widgetIsHovered() then
            nk:tooltip('Right Click To Copy')
        end
        PS.codeState = nk:edit('box', PS.set.code)
    end
    nk:windowEnd()

    if nk:windowBegin('Editor', set.MIDWID, 0, set.EDWID, set.EDHEI,
            'border', 'title', 'movable','minimizable') then

        nk:layoutRow('dynamic',set.BIGROW, 5)
        if nk:button('New') then PS.new() end
        if nk:button('Import') then PS.import() end
        if nk:button('Export') then PS.export() end
        if nk:button('Setup') then PS.hotset.value = not PS.hotset.value end
        if nk:button('Clear') then PS.clearParticles() end

        nk:layoutRow('dynamic',set.ROW, 4)
        nk:label('Mode')
        nk:radio('top',PS.set.mode)
        nk:radio('bottom',PS.set.mode)
        nk:radio('random',PS.set.mode)

        nk:layoutRow('dynamic',set.ROW, set.SINGLAYOUT)
        if nk:button('Buffer') then
            PS.buffer()
        end
        nk:slider(0, PS.set.buffer, set.PBUFFER, 1)
        nk:label(PS.set.buffer.value)

        nk:layoutRow('dynamic',set.ROW, set.SINGLAYOUT)
        if nk:button('Emit') then
            PS.emit()
        end
        nk:slider(1, PS.set.emit, set.PEMIT, 1)
        nk:label(PS.set.emit.value)

        nk:layoutRow('dynamic',set.ROW, set.SINGLAYOUT)
        if nk:button('Lifetime') then
            PS.lifetime()
        end
        nk:slider(-1, PS.set.lifetime, set.PTIME,1)
        nk:label(PS.set.lifetime.value)

        nk:layoutRow('dynamic', set.BIGROW,{0.2,0.3,0.3,0.2})
        if nk:button('Load') then
            PS.loadImd()
        end
        nk:edit('field',PS.set.loadpath)
        if nk:comboboxBegin('Select') then
            nk:layoutRow('dynamic', set.ROW,1)
            nk:radio('none',PS.set.imgdata)
            for k,_ in pairs(PS.imgdata) do
                nk:layoutRow('dynamic', set.ROW,1)
                nk:radio(k,PS.set.imgdata)
            end
            nk:comboboxEnd()
        end
        nk:label(PS.set.imgdata.value,'centered')

        local imageData = PS.imgdata[PS.set.imgdata.value]
        local imdwid,imdhei
        if imageData then
            imdwid,imdhei=imageData:getDimensions()
        end

        nk:layoutRow('dynamic',set.ROW, set.DOUBLAYOUT)
        nk:label('Quads Cols')
        nk:slider(1, PS.set.qCols, set.PQUAD, 1)
        nk:label(PS.set.qCols.value)
        nk:label('Rows')
        nk:slider(1, PS.set.qRows, set.PQUAD, 1)
        nk:label(PS.set.qRows.value)

        nk:layoutRow('dynamic', set.ROW,{0.14,0.16,0.18,0.20,0.19,0.13})
        for i=1,#PS.forms do
             nk:radio(PS.forms[i], PS.set.form)
        end

        local oldwid, oldhei
        oldwid = PS.set.wid.value
        oldhei = PS.set.hei.value
        nk:layoutRow('dynamic',set.ROW, set.SINGLAYOUT)
        nk:label('Width')
        nk:slider(0, PS.set.wid, set.PWH, 1)
        nk:label(PS.round(PS.set.wid.value))

        nk:layoutRow('dynamic',set.ROW, set.SINGLAYOUT)
        nk:label('Height')
        nk:slider(0, PS.set.hei, set.PWH, 1)
        nk:label(PS.round(PS.set.hei.value))

        if imageData then
            PS.set.wid.value=imdwid/PS.set.qCols.value
            PS.set.hei.value=imdhei/PS.set.qRows.value
        end

        if oldwid~=PS.set.wid.value then
            PS.set.offsetX.value = PS.set.wid.value/2
        end
        if oldhei~=PS.set.hei.value then
            PS.set.offsetY.value = PS.set.hei.value/2
        end
        nk:layoutRow('dynamic',set.ROW,set.DOUBLAYOUT)
        nk:label('Offset X')
        nk:slider(0, PS.set.offsetX, PS.set.wid.value, 1)
        nk:label(PS.round(PS.set.offsetX.value))
        nk:label('Offset Y')
        nk:slider(0, PS.set.offsetY,PS.set.hei.value,1)
        nk:label(PS.round(PS.set.offsetY.value))

        local colors = #PS.set.color
        nk:layoutRow('dynamic', set.BIGROW, colors)
        for i=1,colors do
            local clr = PS.set.color[i]
            local color = nuklear.colorRGBA(clr[1]*255,clr[2]*255,
                                            clr[3]*255,clr[4]*255)
            if nk:comboboxBegin(nil, color) then
                local rgba = {'R',clr[1],'G',clr[2],'B',clr[3],'A',clr[4]}

                for j=1, #rgba,2 do
                    nk:layoutRow('dynamic',set.ROW, {0.1,0.7,0.2})
                    nk:label(rgba[j])
                    rgba[j+1] = PS.round(nk:slider(0, rgba[j+1], 1, 0.01),3)
                    nk:label(rgba[j+1])
                end
                PS.set.color[i]={rgba[2],rgba[4],rgba[6],rgba[8]}
                nk:comboboxEnd()
            end
        end

        nk:layoutRow('dynamic',set.ROW, set.SINGLAYOUT)
        nk:label('Rate')
        nk:slider(0, PS.set.rate, set.PEMIT, 1)
        nk:label(PS.set.rate.value)

        nk:layoutRow('dynamic',set.ROW, 4)
        nk:checkbox('outside', PS.set.areaDir)
        nk:radio('none',PS.set.areaForm)
        nk:radio('uniform',PS.set.areaForm)
        nk:radio('normal',PS.set.areaForm)
        nk:layoutRow('dynamic',set.ROW, 3)
        nk:radio('ellipse',PS.set.areaForm)
        nk:radio('borderellipse',PS.set.areaForm)
        nk:radio('borderrectangle',PS.set.areaForm)

        nk:layoutRow('dynamic',set.ROW,set.DOUBLAYOUT)
        nk:label('Emit Area X')
        nk:slider(0, PS.set.areaX, set.VIEWWID/2, 1)
        nk:label(PS.set.areaX.value)
        nk:label('Y')
        nk:slider(0, PS.set.areaY, set.VIEWWID/2, 1)
        nk:label(PS.set.areaY.value)

        nk:layoutRow('dynamic',set.ROW,set.SINGLAYOUT)
        nk:label('Emit Angle')
        nk:slider(0, PS.set.areaAng, set.PI2, 0.01)
        nk:label(PS.round(PS.set.areaAng.value))

        nk:layoutRow('dynamic',set.ROW,set.DOUBLAYOUT)
        nk:label('Size Start')
        nk:slider(0, PS.set.sizeStart, set.PSIZE, 0.01)
        nk:label(PS.round(PS.set.sizeStart.value))
        nk:label('Final')
        nk:slider(0, PS.set.sizeFinal, set.PSIZE, 0.01)
        nk:label(PS.round(PS.set.sizeFinal.value))

        nk:layoutRow('dynamic',set.ROW,set.SINGLAYOUT)
        nk:label('Size Var')
        nk:slider(0, PS.set.sizeVar, 1, 0.01)
        nk:label(PS.round(PS.set.sizeVar.value))

        nk:layoutRow('dynamic',set.ROW,set.DOUBLAYOUT)
        nk:label('Time Min')
        nk:slider(0, PS.set.timeMin, PS.set.timeMax.value, 0.1)
        nk:label(PS.round(PS.set.timeMin.value))
        nk:label('Max')
        nk:slider(PS.set.timeMin.value, PS.set.timeMax, set.PTIME, 0.1)
        nk:label(PS.round(PS.set.timeMax.value))

        nk:layoutRow('dynamic',set.ROW,set.SINGLAYOUT)
        nk:label('Speed Min')
        nk:slider(0, PS.set.speedMin, set.PSPEED, 1)
        nk:label(PS.set.speedMin.value)
        nk:layoutRow('dynamic',set.ROW, set.SINGLAYOUT)
        nk:label('Speed Max')
        nk:slider(PS.set.speedMin.value, PS.set.speedMax,set.PSPEED,1)
        nk:label(PS.set.speedMax.value)

        nk:layoutRow('dynamic',set.ROW,set.SINGLAYOUT)
        nk:label('Acc X Min')
        nk:slider(-set.PSPEED, PS.set.accXMin, set.PSPEED, 1)
        nk:label(PS.set.accXMin.value)
        nk:layoutRow('dynamic',set.ROW, set.SINGLAYOUT)
        nk:label('Acc X Max')
        nk:slider(PS.set.accXMin.value, PS.set.accXMax,set.PSPEED,1)
        nk:label(PS.set.accXMax.value)

        nk:layoutRow('dynamic',set.ROW,set.SINGLAYOUT)
        nk:label('Acc Y Min')
        nk:slider(-set.PSPEED, PS.set.accYMin, set.PSPEED, 1)
        nk:label(PS.set.accYMin.value)
        nk:layoutRow('dynamic',set.ROW, set.SINGLAYOUT)
        nk:label('Acc Y Max')
        nk:slider(PS.set.accYMin.value, PS.set.accYMax,set.PSPEED,1)
        nk:label(PS.set.accYMax.value)

        nk:layoutRow('dynamic',set.ROW,set.SINGLAYOUT)
        nk:label('Rad Acc Min')
        nk:slider(-set.PSPEED, PS.set.radAccMin, set.PSPEED, 1)
        nk:label(PS.set.radAccMin.value)
        nk:layoutRow('dynamic',set.ROW, set.SINGLAYOUT)
        nk:label('Rad Acc Max')
        nk:slider(PS.set.radAccMin.value, PS.set.radAccMax,set.PSPEED,1)
        nk:label(PS.set.radAccMax.value)

        nk:layoutRow('dynamic',set.ROW,set.SINGLAYOUT)
        nk:label('Tan Acc Min')
        nk:slider(-set.PSPEED, PS.set.tanAccMin, set.PSPEED, 1)
        nk:label(PS.set.tanAccMin.value)
        nk:layoutRow('dynamic',set.ROW, set.SINGLAYOUT)
        nk:label('Tan Acc Max')
        nk:slider(PS.set.tanAccMin.value, PS.set.tanAccMax,set.PSPEED,1)
        nk:label(PS.set.tanAccMax.value)

        nk:layoutRow('dynamic',set.ROW,set.DOUBLAYOUT)
        nk:label('Damp Min')
        nk:slider(0, PS.set.dampMin, PS.set.dampMax.value, 0.01)
        nk:label(PS.round(PS.set.dampMin.value))
        nk:label('Max')
        nk:slider(PS.set.dampMin.value, PS.set.dampMax, 1, 0.01)
        nk:label(PS.round(PS.set.dampMax.value))

        nk:layoutRow('dynamic',set.ROW, set.DOUBLAYOUT)
        nk:label('Direction')
        nk:slider(0, PS.set.dir, set.PI2, 0.01)
        nk:label(PS.round(PS.set.dir.value))
        nk:label('Spread')
        nk:slider(0, PS.set.spread, set.PI2, 0.01)
        nk:label(PS.round(PS.set.spread.value))

        nk:layoutRow('dynamic',set.ROW,set.DOUBLAYOUT)
        nk:label('Spin Min')
        nk:slider(-set.PI, PS.set.spinMin, set.PI, 0.01)
        nk:label(PS.round(PS.set.spinMin.value))
        nk:label('Max')
        nk:slider(PS.set.spinMin.value, PS.set.spinMax,set.PI,0.01)
        nk:label(PS.round(PS.set.spinMax.value))

        nk:layoutRow('dynamic',set.ROW,set.SINGLAYOUT)
        nk:label('Spin Var')
        nk:slider(0, PS.set.spinVar, 1, 0.01)
        nk:label(PS.round(PS.set.spinVar.value))

        nk:layoutRow('dynamic',set.ROW,set.DOUBLAYOUT)
        nk:label('Rotate Min')
        nk:slider(0, PS.set.rotateMin, set.PI2, 0.01)
        nk:label(PS.round(PS.set.rotateMin.value))
        nk:label('Max')
        nk:slider(PS.set.rotateMin.value, PS.set.rotateMax,set.PI2,0.01)
        nk:label(PS.round(PS.set.rotateMax.value))

        nk:layoutRow('dynamic',set.ROW,1)
        nk:selectable('RelativeRotation', PS.set.relative)
    end
    nk:windowEnd()
    nk:frameEnd()

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
            love.system.setClipboardText(PS.set.code.value)
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

function love.wheelmoved(x, y)
    nk:wheelmoved(x, y)
end

function love.textinput(text)
    nk:textinput(text)
end

function love.quit()
    PS.clearDir()
    print(set.VER, set.APPNAME, 'Editor (love2d)', 'quit')
end
