#!/usr/bin/env lua
-- LPNG
-- 0.2
-- PNG (lua)
-- lpng.lua

-- MIT License
-- Copyright (c) 2020 Alexander Veledzimovich veledz@gmail.com

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

if arg[0] then print('0.2 LPNG PNG (lua)', arg[0]) end
if arg[1] then print('0.2 LPNG PNG (lua)',arg[1]) end

-- lua<5.3
local unpack = table.unpack or unpack
local utf8 = require('utf8')

local PNG = {137, 80, 78, 71, 13, 10, 26, 10}
local IHDR = {73, 72, 68, 82}
local IDAT = {73, 68, 65, 84}
local IEND = {73, 69, 78, 68}

local LPNG = {}
function LPNG.load(path)
    local file = io.open(path,'rb')
    local all = file:read('*a')
    file:close()
    return LPNG.bytes(all)
end

function LPNG.save(path,data)
    local file = io.open(path,'wb')
    file:write(LPNG.chars(data))
    file:close()
end

function LPNG.clone(data,st,fin)
    local result = {}
    for i=1,#data do
        if i>=st and i<=fin then
            result[#result+1]=data[i]
        end
    end
    return result
end

function LPNG.chars(data)
    local code={}
    for i=1, #data do
        code[#code+1]=string.char(data[i])
    end
    return table.concat(code)
end

function LPNG.bytes(chars)
    local result = {}
    for i=1,#chars do
        result[#result+1]=tostring(string.byte(chars:sub(i,i)))
    end
    return result
end

function LPNG.correct(data)
    local png = table.concat(PNG)
    local ihdr = table.concat(IHDR)
    local idat = table.concat(IDAT)
    local iend = table.concat(IEND)
    if png ~= table.concat(data,'',1,#PNG) then
        return false
    end
    local hdr = #PNG+4+#IHDR
    if ihdr~=table.concat(data,'',#PNG+5,hdr) then
        io.write('wrong IHDR\n')
        return false
    end

    local dat = hdr
    for i=dat, #data do
        if data[i]==tostring(IDAT[1]) then
            if (data[i+1]==tostring(IDAT[2]) and
                data[i+2]==tostring(IDAT[3]) and
                data[i+3]==tostring(IDAT[4])) then
                dat=i
                break
            end
        end
    end

    if idat~=table.concat(data,'',dat,dat+3) then
        io.write('wrong IDAT\n')
        return false
    end

    local en = dat+4
    for i=en,#data do
        if data[i]==tostring(IEND[1]) then
            if (data[i+1]==tostring(IEND[2]) and
                data[i+2]==tostring(IEND[3]) and
                data[i+3]==tostring(IEND[4])) then
                en=i
                break
            end
        end
    end
    if iend~=table.concat(data,'',en,en+3) then
        io.write('wrong IEND\n')
        return false
    end
    return 1, hdr+17, dat-4, en+7
end

function LPNG.trim(data)
    local png, ihdr, idat, iend = LPNG.correct(data)

    if not png then return false end
    local result = LPNG.clone(data,png,iend)

    -- local result = LPNG.clone(data,png,ihdr)
    -- local dat = LPNG.clone(data,idat,iend)
    -- for i=1,#dat do
    --     result[#result+1]=dat[i]
    -- end
    return result
end

function LPNG.encode(data1,data2,code)
    data1 = LPNG.trim(data1)
    data2 = LPNG.trim(data2)

    code = code or ''
    if not data1 or not data2 then return false end
    local result = LPNG.clone(data1,1,#data1)
    for i=1,#data2 do
        result[#result+1]=data2[i]
    end
    for i=1,#code do
        result[#result+1]=string.byte(code:sub(i,i))
    end
    return result
end

function LPNG.decode(data)
    local result = {}
    local code = ''
    while true do
        local png, _, _, iend = LPNG.correct(data)
        if png then
            result[#result+1]= LPNG.clone(data, png, iend)
        else
            code=LPNG.chars(data)
            break
        end

        if iend+1>#data then
            break
        end
        data = LPNG.clone(data, iend+1,#data)
    end

    return result, code
end

return LPNG
