#!/usr/bin/env love
-- LOVFL
-- 0.3
-- File Function (love2d)
-- lovfl.lua

-- MIT License
-- Copyright (c) 2018 Alexander Veledzimovich veledz@gmail.com

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


if arg[1] then print('0.3 LOVFL File Function (love2d)', arg[1]) end

-- lua<5.3
local unpack = table.unpack or unpack
local utf8 = require('utf8')

local lovfs = love.filesystem

local FL={}
function FL.loadAll(dir,...)
    local arr = {}
    local exist = lovfs.getInfo(dir)
    if not exist then return arr end

    if dir:sub(#dir) == '/' then dir=dir:sub(1,#dir-1) end

    local files = lovfs.getDirectoryItems(dir)
    for i=1,#files do
        local path = files[i]
        if #dir>0 then
            path = dir..'/'..files[i]
        end
        local base = FL.base(path)
        exist = lovfs.getInfo(path)
        if (exist and exist.type=='file' and FL.isExt(path,...)) then
            arr[base] = path
        end
    end
    return arr
end

function FL.removeAll(dir,rmdir)
    if not dir then return end
    local exist = lovfs.getInfo(dir)
    if not exist then return end

    if dir:sub(#dir) == '/' then dir=dir:sub(1,#dir-1) end

    local function remove(item,rm)
        exist = lovfs.getInfo(item)
        if exist and exist.type=='directory' then
            local files = lovfs.getDirectoryItems(item)
            for i=1,#files do
                local path = files[i]
                if #dir>0 then
                    path = dir..'/'..files[i]
                end
                remove(path,true)
                lovfs.remove(path)
            end
        else
            lovfs.remove(item)
        end
        if rm then
            lovfs.remove(item)
        end
    end
    remove(dir,rmdir)
end

function FL.loadPath(path,...)
    local arr = {}
    local exist = lovfs.getInfo(path)
    if not exist then return arr end

    if exist.type=='file' then
        if FL.isExt(path,...) then
            arr[FL.base(path)] = path
        end
    else
        arr = FL.loadAll(path,...)
    end
    return arr
end

function FL.name(path)
    return path:match('[^/]+$')
end

function FL.base(path)
    return path:match('([^/]+)[%.]')
end

function FL.noext(path)
    return path:match('([^.]+)[%.]')
end

function FL.ext(path)
    return path:match('[^.]+$')
end

function FL.isExt(path,...)
    local extensions={...}
    local ext = FL.ext(path)
    local ans = false
    for e=1,#extensions do
        if extensions[e] == ext then ans = true end
    end
    return ans
end

function FL.tree(dir,arr,verbose)
    dir = dir or ''
    arr = arr or {}
    if dir:sub(#dir) == '/' then dir=dir:sub(1,#dir-1) end
    local files = lovfs.getDirectoryItems(dir)
    if verbose then print('dir', dir) end
    for i=1, #files do
        local path = files[i]
        if #dir>0 then
            path = dir..'/'..files[i]
        end
        if lovfs.getInfo(path).type=='file' then
            arr[#arr+1] = path
            if verbose then print(#arr,path) end
        elseif lovfs.getInfo(path).type=='directory' then
            FL.tree(path,arr,verbose)
        end
    end
    return arr
end

function FL.loadFile(path)
    local file = io.open(path,'r')
    local content = file:read('*a')
    file:close()
    return content
end

function FL.saveFile(path,datastr)
    local file = io.open(path,'w')
    file:write(datastr)
    file:close()
end

function FL.appendFile(path,datastr)
    local file = io.open(path,'a')
    file:write(datastr)
    file:close()
end

function FL.copyFile(path,dir)
    local newpath = dir..'/'..FL.name(path)
    local datastr = FL.loadFile(path)
    FL.saveFile(newpath,datastr)
end

function FL.loadLove(path,...)
    local chunk, err = lovfs.load(path)
    if not err then return chunk(...) end
end

function FL.loadLoveFile(path)
    local file = lovfs.newFile(path,'r')
    local content = file:read()
    file:close()
    return content
end

function FL.saveLoveFile(path,datastr,open)
    local file = lovfs.newFile(path,'w')
    file:write(datastr)
    file:close()
    if open then
        love.system.openURL('file://'..lovfs.getSaveDirectory())
    end
end

-- love.filedropped(file)
function FL.copyLove(file,dir,open)
    dir = dir or ''
    if not lovfs.getInfo(dir) then lovfs.createDirectory(dir) end
    local filename = file:getFilename()
    FL.copyFile(filename, lovfs.getSaveDirectory()..'/'..dir)
    if open then
        love.system.openURL('file://'..lovfs.getSaveDirectory())
    end
    return filename
end

return FL
