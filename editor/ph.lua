-- Wed Aug  7 20:43:04 2019
-- (c) Alexander Veledzimovich

-- ph PHOTON

-- lua<5.3
local utf8 = require('utf8')
local unpack = table.unpack or unpack

local fl = require('lib/lovfl')
local imd = require('lib/lovimd')

local set = require('editor/set')

local PH = {}
PH.count=0
PH.forms={'circle','ellipse','triangle','rectangle','hexagon','star'}
PH.code={value=''}
PH.name=''
PH.set={
        emit={value=1},
        mode={value='top'},buffer={value=256},lifetime={value=-1},
        qCols={value=1},qRows={value=1},
        form={value='circle'},
        wid={value=8},hei={value=8},offsetX={value=4},offsetY={value=4},
        color={{0.0,0.0,0.0,0.0},{1.0,1.0,1,0.3},{1.0,1.0,1,0.6},
                {1.0,1.0,1,0.9},{1.0,1.0,1,0.6},{1.0,1.0,1.0,0.0}},
        rate={value=1},
        areaForm={value='none'},areaX={value=0},areaY={value=0},
        areaAng={value=0},areaDir={value=false},
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

    local tx = love.graphics.newImage(self:getImageData())
    self.particle = love.graphics.newParticleSystem(tx, self.set.buffer.value)
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
        cloned[key]=tab
    end
    return cloned
end

function PH:saveImd()
    local imgname = self.name..'/'..self:pathImd()
    self:getImageData():encode('png',imgname)
end

function PH:pathImd()
    return self.name..'.png'
end

function PH:setName()
    self.name = self.set.form.value..os.time()
end

function PH:getQuads()
    local imageData = self.PS.imgbase[self.set.form.value]
    if not imageData then return end
    local sx, sy = imageData:getDimensions()
    return imd.quads(imageData,
            sx/self.set.qCols.value, sy/self.set.qRows.value,
            self.set.qCols.value,self.set.qRows.value)
end

function PH:getImageData()
    local texture
    local imageData = self.PS.imgbase[self.set.form.value]
    if imageData then
        texture = imageData
    else
        texture = imd.form(self.set.form.value,{1,1,1,1},
                self.set.wid.value,self.set.hei.value)
    end
    return texture
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
    self:setName()
    self.particle:setInsertMode(self.set.mode.value)

    self.particle:setTexture(love.graphics.newImage(self:getImageData()))
    if not self.forms[self.set.form] then
        self.particle:setQuads(self:getQuads())
    end

    self.particle:setOffset(self.set.offsetX.value,self.set.offsetY.value)
    local clr = {}
    for i=1, #self.set.color do
        for j=1, #self.set.color[i] do clr[#clr+1] = self.set.color[i][j] end
    end
    self.particle:setColors(unpack(clr))

    self.particle:setEmissionRate(self.set.rate.value)
    self.particle:setEmissionArea(
            self.set.areaForm.value,
            self.set.areaX.value,self.set.areaY.value,
            self.set.areaAng.value,self.set.areaDir.value
        )

    self.particle:setSizes(self.set.size1.value,self.set.size2.value,self.set.size3.value,
                self.set.size4.value,self.set.size5.value,self.set.size6.
                value,self.set.size7.value,self.set.size8.value)
    self.particle:setSizeVariation(self.set.sizeVar.value)

    self.particle:setParticleLifetime(self.set.timeMin.value,
                                 self.set.timeMax.value)

    self.particle:setSpeed(self.set.speedMin.value,self.set.speedMax.value)
    self.particle:setLinearAcceleration(self.set.accXMin.value,
                                   self.set.accYMin.value,
                                   self.set.accXMax.value,
                                   self.set.accYMax.value)
    self.particle:setRadialAcceleration(self.set.radAccMin.value,
                                   self.set.radAccMax.value)
    self.particle:setTangentialAcceleration(self.set.tanAccMin.value,
                                        self.set.tanAccMax.value)
    self.particle:setLinearDamping(self.set.dampMin.value,self.set.dampMax.value)

    self.particle:setDirection(self.set.dir.value)
    self.particle:setSpread(self.set.spread.value)

    self.particle:setSpin(self.set.spinMin.value,
                     self.set.spinMax.value)
    self.particle:setSpinVariation(self.set.spinVar.value)

    self.particle:setRotation(self.set.rotateMin.value,
                         self.set.rotateMax.value)

    self.particle:setRelativeRotation(self.set.relative.value)

    self.code.value = self:generate()
end

function PH:emit()
    self.particle:emit(self.set.emit.value)
end

function PH:generate()
    local clr = {}
    for i=1, #self.set.color do
        for j=1, #self.set.color[i] do clr[#clr+1] = self.set.color[i][j] end
    end

    local code = [[
-- ]]..set.VER..' '..set.APPNAME..[[ Editor (love2d)

local unpack = table.unpack or unpack
local quads
local function photon()
    local imd = love.image.newImageData(']]..set.DEFPATH..'/'..self:pathImd()..[[')
    local tx = love.graphics.newImage(imd)
    local ph = love.graphics.newParticleSystem(tx,]]..self.set.buffer.value..[[)
    ph:setEmitterLifetime(]]..self.set.lifetime.value..[[)
    ph:setInsertMode(']]..self.set.mode.value..[[')
    if ]]..tostring(not self.forms[self.set.form.value])..[[ then
        ph:setQuads(unpack(quads(imd,]]..self.set.qCols.value..[[,]]..self.set.qRows.value..[[)))
    end
    ph:setOffset(]]..self.set.offsetX.value..[[,]]..self.set.offsetY.value..[[)
    ph:setColors(]]..table.concat(clr,',')..[[)
    ph:setEmissionRate(]]..self.set.rate.value..[[)
    ph:setEmissionArea(']]..self.set.areaForm.value..[[',]]..self.set.areaX.value..[[,]]..self.set.areaY.value..[[,]]..self.set.areaAng.value..[[,]]..tostring(self.set.areaDir.value)..[[)
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

return PH
