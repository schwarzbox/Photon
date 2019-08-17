-- Tue Aug  6 00:54:24 2019
-- (c) Alexander Veledzimovich
-- set PHOTON

-- lua<5.3
local utf8 = require('utf8')
local unpack = table.unpack or unpack

local SET = {
    APPNAME = love.window.getTitle(),
    VER = '0.8',
    SAVE = 'photonsave.lua',
    FULLSCR = love.window.getFullscreen(),
    WID = love.graphics.getWidth(),
    HEI = love.graphics.getHeight(),
    MIDWID = love.graphics.getWidth() / 2,
    MIDHEI = love.graphics.getHeight() / 2,
    SCALE = {1,1},
    DELAY = 0.4,

    EMPTY = {0,0,0,0},
    WHITE = {1,1,1,1},
    BLACK = {0,0,0,1},
    RED = {1,0,0,1},
    GREEN = {0,1,0,1},
    BLUE = {0,0,1,1},
    GRAY = {0.5,0.5,0.5,1},
    DARKGRAY = {32/255,32/255,32/255,1},
    MAINFNT = nil,

    GROUPMARGIN = 5,
    SINGHEI = 16,
    DOUBHEI = 25,
    COLORHEI = 20,

    MARKRAD = 4,

    IMGEXT = {'png','jpg'},
    PHTEXT = 'pht',
    TMPDIR = 'tmp',
    DEFPATH = 'res/pht',

    PBUFFER = 65536,
    PWH = 512,
    PSIZE = 8,
    PEMIT = 2048,
    PTIME = 64,
    PSPEED = 2048,
    PI = math.pi,
    PI2 = math.pi*2,
    PQUAD = 16,
}

SET.VIEWWID = SET.MIDWID
SET.VIEWHEI = SET.MIDHEI
SET.CODEWID = SET.MIDWID
SET.CODEHEI = SET.MIDHEI
SET.EDWID = SET.MIDWID
SET.EDHEI = SET.HEI

SET.BGCLR = SET.DARKGRAY
SET.TXTCLR = SET.WHITE

return SET
