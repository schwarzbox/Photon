#!/usr/bin/env love
-- LOVIMD
-- 0.2
-- Image Functions (love2d)
-- lovimd.lua

-- MIT License
-- Copyright (c) 2018 Aliaksandr Veledzimovich veledz@gmail.com

-- Permission is hereby granted, free of charge, to any person obtaining a
-- copy of this software and associated documentation files (the "Software"),
-- to deal in the Software without restriction, including without limitation
-- the rights to use, copy, modify, merge, publish, distribute, sublicense,
-- and/or sell copies of the Software, and to permit persons to whom the
-- Software is furnished to do so, subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF AfNY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
-- FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
-- DEALINGS IN THE SOFTWARE.

-- 0.3
-- improve gradient (circular linear)
-- 1d array
-- improve splash (with noise)

if arg[1] then print('0.25 LOVIMG Image Functions (love2d)', arg[1]) end

-- old lua version
local unpack = table.unpack or unpack
local utf8 = require('utf8')

local EMPTY = {1,1,1,0}
local WHITE = {1,1,1,1}
local BLACK = {0,0,0,1}

local IMD = {}
function IMD.fromData(imgdata)
    local arr={}
    local sx, sy=imgdata:getDimensions()
    for y=1, sy do
        local row={}
        for x=1, sx do
            local _,_,_,a = imgdata:getPixel(x-1, y-1)
            if a==0 then row[x]=0 else row[x] = 1 end
        end
        arr[y] = row
    end
    return arr
end

function IMD.fromMatrix(matrix,color,scale)
    scale = scale or 1
    local sx = #matrix[1]
    local sy = #matrix
    local data = love.image.newImageData(sx, sy)
    for y=1,sy do
        for x=1,sx do
            if matrix[y][x] and matrix[y][x]~=0 then
                local value = matrix[y][x]
                local clr = {value,value,value,1}
                data:setPixel((x-1),(y-1), unpack(color or clr))
            end
        end
    end
    if scale~=1 then data = IMD.resize(data, scale) end
    return data
end

function IMD.fromText(text,size,color,fnt)
    text = text or ' '
    size = size or 16
    color = color or WHITE
    local font
    if fnt then font = love.graphics.newFont(fnt,size)
    else font = love.graphics.newFont(size) end

    local sx,sy = font:getWidth(text),font:getHeight()
    local canvas = love.graphics.newCanvas(sx,sy)
    love.graphics.setCanvas(canvas)
    love.graphics.setFont(font)
    love.graphics.setColor(color)
    love.graphics.setBlendMode('alpha')
    love.graphics.print(text)
    love.graphics.setColor(WHITE)
    love.graphics.setCanvas()
    local data = canvas:newImageData()
    return data
end

function IMD.resize(imgdata,scale)
    scale = scale or 1
    local sx, sy = imgdata:getDimensions()
    local data = love.image.newImageData(math.ceil(sx*scale),
                                          math.ceil(sy*scale))
    for x=1, sx do
        for y=1, sy do
            local r,g,b,a = imgdata:getPixel(x-1, y-1)
            local initx = math.floor((x-1)*scale)
            local inity = math.floor((y-1)*scale)
            data:setPixel(initx,inity, r,g,b,a)
            for dx=0,scale-1 do
                for dy=0,scale-1 do
                    data:setPixel(initx+dx,inity+dy, r,g,b,a)
                end
            end
        end
    end
    return data
end

function IMD.rotate(imgdata,side)
    local sx, sy = imgdata:getDimensions()
    local data
    if side=='CW' or side=='CCW' then
        data = love.image.newImageData(sy,sx)
    else
        data = love.image.newImageData(sx,sy)
    end
    local initx
    local inity
    for x=1,sx do
        for y=1,sy do
            local r,g,b,a = imgdata:getPixel(x-1, y-1)
            if side=='CW' then
                initx = sy-y
                inity = x-1
            elseif side=='CCW' then
                initx = y-1
                inity = sx-x
            elseif side=='HFLIP' then
                initx = sx-x
                inity = y-1
            elseif side=='VFLIP' then
                initx = x-1
                inity = sy-y
            else
                initx = x-1
                inity = sy-y
            end
            data:setPixel(initx,inity, r,g,b,a )
        end
    end
    return data
end

function IMD.crop(imgdata,x1,y1,x2,y2)
    local sx,sy = imgdata:getDimensions()
    if not x1 and not y1 and not x2 and not y2 then
        x1=sx y1=sy x2=0 y2=0
        for x=1, sx do
            for y=1, sy do
                local _,_,_,a = imgdata:getPixel(x-1, y-1)
                if a~=0 then
                    if x<x1 then x1=x end
                    if y<y1 then y1=y end
                    if x>x2 then x2=x end
                    if y>y2 then y2=y end
                end
            end
        end
    end
    sx=x2-x1
    sy=y2-y1
    if sx<=0 then sx=1 end
    if sy<=0 then sy=1 end

    local data=love.image.newImageData(sx,sy)
    data:paste(imgdata,0,0,x1,y1,sx,sy)
    return data
end

function IMD.quads(imgdata,wid,hei,cols,rows)
    local quads = {}
    local sx, sy = imgdata:getDimensions()
    for y=0,rows-1 do
        for x=0,cols-1 do
            quads[#quads+1]=love.graphics.newQuad(
                    wid*x,hei*y,wid,hei,sx,sy)
        end
    end
    return quads
end

function IMD.slice(imgdata,wid,hei,cols,rows)
    cols = cols or 1
    rows = rows or 1
    local sx, sy = imgdata:getDimensions()
    local arr = {}
    for y=0,rows-1 do
        for x=0,cols-1 do
            local data = love.image.newImageData(wid,hei)
            -- source, destx, desty, sourcex, sourcey, source wid, source hei
            data:paste(imgdata,0,0,x*wid, y*hei,sx,sy)
            arr[#arr+1] = data
        end
    end
    return arr
end

function IMD.mask(imgdata,color,randalpha)
    color = color or BLACK
    local sx, sy = imgdata:getDimensions()
    local data = love.image.newImageData(sx,sy)
    for x=1, sx do
        for y=1, sy do
            local _,_,_,a = imgdata:getPixel(x-1, y-1)
            if a~=0 then
                if randalpha then
                    color = {color[1],color[2],color[3],love.math.random()}
                end
                data:setPixel(x-1,y-1, unpack(color))
            end
        end
    end
    return data
end

-- blend
-- add subtract replace screen
function IMD.screenshot(filename,x, y, wid, hei)
    x=x or 0
    y=y or 0
    wid=wid or love.graphics.getWidth()
    hei=hei or love.graphics.getHeight()

    love.graphics.captureScreenshot(function(imgdata)
                    imgdata = IMD.crop(imgdata,x,y,x+wid,y+hei)
                    imgdata:encode('png',filename)
            end)
end

function IMD.merge(imgdata1,imgdata2,x,y,blend)
    x = x or 0
    y = y or 0
    blend = blend or 'alpha'
    local sx, sy = imgdata1:getDimensions()
    local canvas = love.graphics.newCanvas(sx,sy)
    love.graphics.setCanvas(canvas)
    love.graphics.setBlendMode(blend)
    love.graphics.draw(love.graphics.newImage(imgdata1))
    love.graphics.draw(love.graphics.newImage(imgdata2),x,y)
    love.graphics.setBlendMode('alpha')
    love.graphics.setCanvas()
    local data = canvas:newImageData()
    return data
end

function IMD.concat(imgdata1,imgdata2,side)
    side = side or 'right'
    local sx1, sy1 = imgdata1:getDimensions()
    local sx2, sy2 = imgdata2:getDimensions()
    local sx = (sx1>sx2) and sx1 or sx2
    local sy = (sy1>sy2) and sy1 or sy2

    local x1,y1, x2,y2, canvas
    if side == 'left' then
        canvas = love.graphics.newCanvas(sx1+sx2,sy)
        x1,y1 = sx2,0
        x2,y2 = 0,0
    elseif side == 'top' then
        canvas = love.graphics.newCanvas(sx,sy1+sy2)
        x1,y1 = 0,sy2
        x2,y2 = 0,0
    elseif side == 'bot' then
        canvas = love.graphics.newCanvas(sx,sy1+sy2)
        x1,y1 = 0,0
        x2,y2 = 0,sy1
    else
        canvas = love.graphics.newCanvas(sx1+sx2,sy)
        x1,y1 = 0,0
        x2,y2 = sx1,0
    end
    love.graphics.setCanvas(canvas)
    love.graphics.draw(love.graphics.newImage(imgdata1),x1,y1)
    love.graphics.draw(love.graphics.newImage(imgdata2),x2,y2)
    love.graphics.setCanvas()
    local data = canvas:newImageData()
    return data
end

function IMD.splash(imgdata,num,radius,background,border)
    local sx, sy = imgdata:getDimensions()
    local data = love.image.newImageData(sx,sy)
    data:paste(imgdata,0,0,0,0,sx,sy)
    num = num or 5
    radius = radius or 10
    radius = math.floor(math.min(radius,math.min(sx/2,sy/2)))-2
    background = background or {0,0,0,0}
    border = border or {0,0,0,1}
    local mod = {{1,1},{-1,1},{1,-1},{-1,-1}}
    for _=1,num do
        local randrad = love.math.random(radius)
        local allpx = IMD.circleAllPixels(randrad)
        local dots = IMD.circlePixels(randrad)
        local cenx = love.math.random(radius+2,sx-radius-2)
        local ceny = love.math.random(radius+2,sy-radius-2)

        for i=1, #allpx do
            if i%randrad==0 then
                data:setPixel(cenx+allpx[i][1],
                              ceny+allpx[i][2],background)
            end
        end
        for i=1,#dots do
            local _,_,_,a = imgdata:getPixel(cenx+dots[i][1],
                                                ceny+dots[i][2])
            if a>0  then
                if i%randrad==0 then
                    for m=1, #mod do
                        data:setPixel(cenx+mod[m][1]+dots[i][1],
                                  ceny+mod[m][2]+dots[i][2],
                                {border[1],border[2],border[3],
                                love.math.random()})
                    end
                end
            end
        end
        for _=1,#dots/4 do
            local coords=allpx[love.math.random(#allpx)]
            for m=1,#mod do
                data:setPixel(cenx+mod[m][1]+coords[1],
                              ceny+mod[m][2]+coords[2],background)
            end
        end
    end
    return data
end

function IMD.rand(imgdata,num,fill,...)
    local sx, sy = imgdata:getDimensions()
    fill = fill or false
    num = num or 10
    local colors = {...}
    if #colors==0 then colors = {BLACK} end
    local color = colors[1]
    for _=1,num do
        local a = 0
        local x = love.math.random(1,sx)
        local y = love.math.random(1,sy)
        while a==0 and fill do
            x = love.math.random(1,sx)
            y = love.math.random(1,sy)
            _,_,_,a = imgdata:getPixel(x-1, y-1)
        end
        if #colors>1 then
            color = colors[love.math.random(#colors)]
        end
        imgdata:setPixel(x-1,y-1,unpack(color))
    end
    return imgdata
end

function IMD.gradient(imgdata)
    local sx, sy = imgdata:getDimensions()
    local data = love.image.newImageData(sx,sy)
    local msx,msy = math.floor(sx/2), math.floor(sy/2)
    local r,g,b,a = imgdata:getPixel(msx, msy)
    local step = a/msx
    for i=1,msx do
        local tmp = IMD.circlePixels(i-1)
        a = a - step
        for j=1, #tmp do
            data:setPixel(msx+tmp[j][1], msy+tmp[j][2],{r,g,b,a})
        end
    end
    return data
end

function IMD.blur(imgdata,radius,step)
    local sx, sy = imgdata:getDimensions()
    local data = love.image.newImageData(sx,sy)
    radius=radius or 4
    step=step or 1
    local allpx = IMD.circleAllPixels(radius)
    for x=1, sx,step do
        for y=1, sy,step do
            local r,g,b,a
            local sum={0,0,0,0}
            local total=0
            for i=1,#allpx do
                local locx=(x-1)+allpx[i][1]
                local locy=(y-1)+allpx[i][2]

                if locx>0 and locx<sx and locy>0 and locy<sy then
                    r,g,b,a=imgdata:getPixel(locx,locy)
                    sum[1]=sum[1]+r
                    sum[2]=sum[2]+g
                    sum[3]=sum[3]+b
                    sum[4]=sum[4]+a
                    total=total+1
                end
            end
            data:setPixel(x-1, y-1,{sum[1]/total,sum[2]/total,
                                    sum[3]/total,sum[4]/total})
        end
    end
    return data
end

function IMD.contrast(imgdata,contrast)
    local sx, sy = imgdata:getDimensions()
    local data = love.image.newImageData(sx,sy)
    for x=1, sx do
        for y=1, sy do
            local r,g,b,a = imgdata:getPixel(x-1, y-1)
            if a>contrast then
                data:setPixel(x-1,y-1, r,g,b,1)
            end
        end
    end
    return data
end

function IMD.form(form,color,sx,sy,vertex,fill)
    form = form or 'line'
    sx = sx>=1 and sx or 1
    sy = sy>=1 and sy or sx
    vertex = vertex or {}
    fill = fill or 'fill'

    local midwid = sx / 2
    local midhei = sy / 2
    if form == 'triangle' then
        vertex = {0,0,sx,midhei,0,sy}
    elseif form == 'pentagon' then
        local pentWid = sx * 0.381966011727603 * 0.5
        local pentHei = sy * 0.381966011727603
            vertex = {midwid, 0, sx, pentHei, sx-pentWid, sy,
                        pentWid, sy, 0, pentHei}
    elseif form == 'hexagon' then
        local hexhei = sy * 0.25
        vertex = {midwid, 0, sx, hexhei, sx, sy-hexhei,
                midwid, sy, 0, sy-hexhei, 0, hexhei}
    elseif form == 'star' or form == 'pentagram' then
        local pentWid = sx * 0.381966011727603 * 0.5
        local pentHei = sy * 0.381966011727603

        local starMinWid = sx * 0.116788321167883
        local starMaxWid = sx * 0.187956204379562
        local starMinHei = sy * 0.62043795620438
        local starMaxHei = sy * 0.755474452554745

       vertex = {midwid, 0, midwid+starMinWid, pentHei,
                sx, pentHei, midwid+starMaxWid, starMinHei,
                sx-pentWid, sy, midwid, starMaxHei,
                pentWid, sy, midwid-starMaxWid, starMinHei,
                0, pentHei, midwid-starMinWid, pentHei, midwid, 0}
    end

    color = color or WHITE
    local forms = {
        ['circle']=function()
            love.graphics.circle(fill,midwid,midhei,midwid) end,
        ['ellipse']=function()
            love.graphics.ellipse(fill,midwid,midhei,midwid,midhei,32) end,
        ['triangle']=function() love.graphics.polygon(fill,vertex) end,
        ['rectangle']=function()love.graphics.rectangle(fill,0,0,sx,sy) end,
        ['pentagon']=function() love.graphics.polygon(fill,vertex) end,
        ['hexagon']=function() love.graphics.polygon(fill,vertex) end,
        ['star']=function()
            love.graphics.polygon('fill',unpack(vertex,11,#vertex))
            local v = {unpack(vertex,3,12)}
            v[#v+1]=vertex[1]
            v[#v+1]=vertex[2]
            love.graphics.polygon('fill',v)
            end,
        ['pentagram']=function() love.graphics.line(vertex) end,
        ['polygon']=function() love.graphics.polygon(fill,vertex) end,
        ['line']=function() love.graphics.line(vertex) end,
        ['arc']=function()
            local ang = math.atan2(midhei,sx)
            love.graphics.arc(fill, 'pie',0,midhei,sx,-ang,ang, 16)
            end,
    }

    local canvas = love.graphics.newCanvas(sx,sy)
    love.graphics.setCanvas(canvas)
    love.graphics.setColor(color)
    forms[form]()
    love.graphics.setColor(WHITE)
    love.graphics.setCanvas()
    local data = canvas:newImageData()

    if form=='star' or form=='pentagram' or form=='pentagon' then
        data = IMD.rotate(data,'CW')
    end
    return data
end

function IMD.tree(ln,sz,ang,rang,rlen,rnode)
    local function drawTree(len,size,angle,randang,randlen,randnode)
        love.graphics.setLineWidth(size)
        local length=len
        if randlen then length=love.math.random(len) end
        love.graphics.line(0,0,0,-length)
        love.graphics.translate(0,-length)

        len=len*0.66
        size=size*0.77
        if len>2 then
            local nodes = 2
            if randnode then
                nodes=love.math.random(4)
            end
            for i=1,nodes do
                local alpha=angle
                if randang then
                    alpha=(love.math.random()*2-1)*math.pi/3
                else
                    if i==2 then alpha=-angle end
                end
                love.graphics.push()
                love.graphics.rotate(alpha)
                drawTree(len,size,angle,randang,randlen,randnode)
                love.graphics.pop()
            end
        end
    end
    local sx=ln*8
    local sy=ln*8
    local canvas = love.graphics.newCanvas(sx,sy)
    love.graphics.setCanvas(canvas)
    love.graphics.push()
    love.graphics.translate(sx/2,sy/2)
    drawTree(ln,sz,ang,rang,rlen,rnode)
    love.graphics.pop()
    love.graphics.setLineWidth(1)
    love.graphics.setCanvas()
    local data = canvas:newImageData()
    return data
end

function IMD.circleAllPixels(radius)
    local  arr = {}
    for i=1,radius do
        local tmp = IMD.circlePixels(i)
        for j=1, #tmp do
            arr[#arr+1] = tmp[j]
        end
    end
    return arr
end

function IMD.circlePixels(radius)
    local arr = {}
    for grad=0,359 do
        grad = math.rad(grad)
        local dotx = radius * math.cos(grad)
        local doty = radius * math.sin(grad)
        arr[#arr+1] = {dotx, doty}
    end
    return arr
end

return IMD
