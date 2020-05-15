-- Wed Aug  7 20:43:04 2019
-- (c) Alexander Veledzimovich
-- ph PHOTON

-- lua<5.3
local utf8 = require('utf8')
local unpack = table.unpack or unpack

local imd = require('lib/lovimd')
local set = require('editor/set')

local PH = {}
PH.count = 0
PH.forms = {'circle','ellipse','triangle','rectangle','hexagon','star'}
PH.code = {value=''}
PH.name = ''
PH.set = {
        pname={value=''},
        emit={value=1},
        mode={value='top'},buffer={value=256},lifetime={value=-1},
        rate={value=1},
        areaForm={value='none'},areaX={value=0},areaY={value=0},
        areaAng={value=0},areaDir={value=false},
        form={value='circle'},
        wid={value=8},hei={value=8},qCols={value=1},qRows={value=1},
        offsetX={value=4},offsetY={value=4},
        color={0.0,0.0,0.0,0.0, 1.0,1.0,1,0.2, 1.0,1.0,1,0.4,
                1.0,1.0,1,0.6, 1.0,1.0,1,0.8, 1.0,1.0,1.0,0.6,
                1.0,1.0,1.0,0.4, 1.0,1.0,1.0,0.0},

        timeMin={value=1},timeMax={value=1},
        size1={value=0},size2={value=0.3},size3={value=0.6},
        size4={value=0.9},size5={value=1},size6={value=0.6},
        size7={value=0.3},size8={value=0},
        sizeVar={value=0},
        speedMin={value=64},speedMax={value=128},
        dampMin={value=0},dampMax={value=0},
        accXMin={value=0},accXMax={value=0},
        accYMin={value=0},accYMax={value=0},
        radAccMin={value=0},radAccMax={value=0},
        tanAccMin={value=0},tanAccMax={value=0},
        dir={value=0},spread={value=0},
        spinMin={value=0},spinMax={value=0},spinVar={value=0},
        rotateMin={value=0},rotateMax={value=0},
        relative={value=false},
}

function PH:new(o)
    o=o or {}
    self.__index = self
    self=setmetatable(o,self)

    self.set=self.clone(self.set)
    self:setImageData()

    self.particle = love.graphics.newParticleSystem(
                self.image,self.set.buffer.value)
    self.particle:setPosition(self.PS.x,self.PS.y)
    self.particle:setEmitterLifetime(self.set.lifetime.value)

    self:setup()
    return self
end

function PH.clone(clone)
    local cloned = {}
    for key,val in pairs(clone) do
        local tab = {}
        for k,v in pairs(val) do tab[k]=v end
        cloned[key] = tab
    end
    return cloned
end

function PH:pathImd()
    return self.name..'.png'
end

function PH:setName()
    if #self.set.pname.value>0 then
        self.name = self.set.pname.value
    else
        self.name = self.set.form.value..os.time()
    end
end

function PH:getQuads()
    local imagedata = self.PS.imgbase[self.set.form.value]
    if not imagedata then return end
    local sx, sy = imagedata:getDimensions()
    return imd.quads(imagedata,
            sx/self.set.qCols.value, sy/self.set.qRows.value,
            self.set.qCols.value,self.set.qRows.value)
end

function PH:setImageData()
    local texture
    local imagedata = self.PS.imgbase[self.set.form.value]
    if imagedata then
        texture = imagedata
    else
        texture = imd.form(self.set.form.value,{1,1,1,1},
                self.set.wid.value,self.set.hei.value)
    end
    self.imagedata = texture
    self.image = love.graphics.newImage(texture)
end

function PH:start() self.particle:start() end

function PH:pause() self.particle:pause() end

function PH:stop() self.particle:stop() end

function PH:reset()
    self.particle:setEmitterLifetime(self.set.lifetime.value)
    self.particle:setBufferSize(self.set.buffer.value)
    self.particle:reset()
end

function PH:setup()
    local sst = self.set
    self:setName()
    self.particle:setInsertMode(sst.mode.value)
    self.particle:setEmissionRate(sst.rate.value)
    self.particle:setEmissionArea(
            sst.areaForm.value,
            sst.areaX.value,sst.areaY.value,
            sst.areaAng.value,sst.areaDir.value
        )

    self.particle:setTexture(self.image)
    if not self.forms[sst.form] then
        self.particle:setQuads(self:getQuads())
    end
    self.particle:setOffset(sst.offsetX.value,sst.offsetY.value)
    self.particle:setColors(unpack(sst.color))
    self.particle:setParticleLifetime(sst.timeMin.value,sst.timeMax.value)
    self.particle:setSizes(sst.size1.value,sst.size2.value,
            sst.size3.value, sst.size4.value,sst.size5.value,
            sst.size6.value,sst.size7.value,sst.size8.value)
    self.particle:setSizeVariation(sst.sizeVar.value)
    self.particle:setSpeed(sst.speedMin.value,sst.speedMax.value)
    self.particle:setLinearAcceleration(sst.accXMin.value,
            sst.accYMin.value,sst.accXMax.value,sst.accYMax.value)
    self.particle:setRadialAcceleration(sst.radAccMin.value,
            sst.radAccMax.value)
    self.particle:setTangentialAcceleration(sst.tanAccMin.value,
            sst.tanAccMax.value)
    self.particle:setLinearDamping(sst.dampMin.value,sst.dampMax.value)
    self.particle:setDirection(sst.dir.value)
    self.particle:setSpread(sst.spread.value)
    self.particle:setSpin(sst.spinMin.value,sst.spinMax.value)
    self.particle:setSpinVariation(sst.spinVar.value)
    self.particle:setRotation(sst.rotateMin.value,sst.rotateMax.value)
    self.particle:setRelativeRotation(sst.relative.value)

    self.code.value = self:generate()
end

function PH:emit()
    self.particle:emit(self.set.emit.value)
end

function PH:import(photon)
    local sst = self.set
    sst.mode.value = photon:getInsertMode()
    sst.buffer.value = photon:getBufferSize()
    self.particle:setBufferSize(sst.buffer.value)
    self.particle:reset()
    sst.rate.value = photon:getEmissionRate()
    sst.areaForm.value,sst.areaX.value,sst.areaY.value,
            sst.areaAng.value,sst.areaDir.value = photon:getEmissionArea()
    local quads = photon:getQuads()
    if #quads>0 then
        local _,_,qw,qh=quads[1]:getViewport()
        local iw,ih=quads[1]:getTextureDimensions()
        sst.qCols.value = iw/qw
        sst.qRows.value = ih/qh
    end
    sst.offsetX.value,sst.offsetY.value = photon:getOffset()
    local color = {photon:getColors()}
    sst.color = {}
    for i=1,#color do
        for j=1,#color[i] do
            sst.color[#sst.color+1] = color[i][j]
        end
    end
    sst.timeMin.value,sst.timeMax.value = photon:getParticleLifetime()
    sst.size1.value,sst.size2.value,
        sst.size3.value, sst.size4.value,sst.size5.value,
        sst.size6.value,sst.size7.value,sst.size8.value = photon:getSizes()
    sst.sizeVar.value = photon:getSizeVariation()
    sst.speedMin.value,sst.speedMax.value = photon:getSpeed()
    sst.accXMin.value, sst.accYMin.value,
            sst.accXMax.value,sst.accYMax.valu = photon:getLinearAcceleration()
    sst.radAccMin.value,
            sst.radAccMax.value = photon:getRadialAcceleration()
    sst.tanAccMin.value,
            sst.tanAccMax.value = photon:getTangentialAcceleration()
    sst.dampMin.value, sst.dampMax.value = photon:getLinearDamping()
    sst.dir.value = photon:getDirection()
    sst.spread.value = photon:getSpread()
    sst.spinMin.value, sst.spinMax.value = photon:getSpin()
    sst.spinVar.value = photon:getSpinVariation()
    sst.rotateMin.value, sst.rotateMax.value = photon:getRotation()
    sst.relative.value = photon:hasRelativeRotation()
end

function PH:generate()
    local code = [[
--lua
--]]..set.VER..' '..set.APPNAME..[[ Editor (love2d)

local unpack = table.unpack or unpack
local quads
local function photon(imd)
    if not imd then
        imd = love.image.newImageData(']]..set.DEFPATH..'/'..self:pathImd()..[[')
    elseif type(imd)=='table' then
        local bytedata = love.data.newByteData(chars(imd))
        imd = love.image.newImageData(bytedata)
    elseif type(imd)=='string' then
        imd = love.image.newImageData(imd)
    end

    local tx = love.graphics.newImage(imd)
    local ph = love.graphics.newParticleSystem(tx,]]..self.set.buffer.value..[[)
    ph:setInsertMode(']]..self.set.mode.value..[[')
    ph:setEmitterLifetime(]]..self.set.lifetime.value..[[)
    ph:setEmissionRate(]]..self.set.rate.value..[[)
    ph:setEmissionArea(']]..self.set.areaForm.value..[[',]]..self.set.areaX.value..[[,]]..self.set.areaY.value..[[,]]..self.set.areaAng.value..[[,]]..tostring(self.set.areaDir.value)..[[)
    if ]]..tostring(not self.forms[self.set.form.value])..[[ then
        ph:setQuads(unpack(quads(imd,]]..self.set.qCols.value..[[,]]..self.set.qRows.value..[[)))
    end
    ph:setOffset(]]..self.set.offsetX.value..[[,]]..self.set.offsetY.value..[[)
    ph:setColors(]]..table.concat(self.set.color,',')..[[)
    ph:setParticleLifetime(]]..self.set.timeMin.value..[[,]]..self.set.timeMax.value..[[)
    ph:setSizes(]]..self.set.size1.value..[[,]]..self.set.size2.value..[[,]]..self.set.size3.value..[[,]]..self.set.size4.value..[[,]]..self.set.size5.value..[[,]]..self.set.size6.value..[[,]]..self.set.size7.value..[[,]]..self.set.size8.value..[[)
    ph:setSizeVariation(]]..self.set.sizeVar.value..[[)
    ph:setSpeed(]]..self.set.speedMin.value..[[,]]..self.set.speedMax.value..[[)
    ph:setLinearAcceleration(]]..self.set.accXMin.value..[[,]]..self.set.accYMin.value..[[,]]..self.set.accXMax.value..[[,]]..self.set.accYMax.value..[[)
    ph:setRadialAcceleration(]]..self.set.radAccMin.value..[[,]]..self.set.radAccMax.value..[[)
    ph:setTangentialAcceleration(]]..self.set.tanAccMin.value..[[,]]..self.set.tanAccMax.value..[[)
    ph:setLinearDamping(]]..self.set.dampMin.value..[[,]]..self.set.dampMax.value..[[)
    ph:setDirection(]]..self.set.dir.value..[[)
    ph:setSpread(]]..self.set.spread.value..[[)
    ph:setSpin(]]..self.set.spinMin.value..[[,]]..self.set.spinMax.value..[[)
    ph:setSpinVariation(]]..self.set.spinVar.value..[[)
    ph:setRotation(]]..self.set.rotateMin.value..[[,]]..self.set.rotateMax.value..[[)
    ph:setRelativeRotation(]]..tostring(self.set.relative.value)..[[)
    return ph
end

function chars(data)
    local code={}
    for i=1, #data do
        code[#code+1]=string.char(data[i])
    end
    return table.concat(code)
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
return photon(...)
]]
    return code
end

return PH
