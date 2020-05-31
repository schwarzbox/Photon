-- Tue Aug  6 00:54:24 2019
-- (c) Alexander Veledzimovich
-- set PHOTON

-- lua<5.3
local utf8 = require('utf8')
local unpack = table.unpack or unpack

local SET = {
    APPNAME = love.window.getTitle(),
    VER = '1.4',
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
    DOUBHEI = 20,
    COLORROWHEI = 20,
    COLORBOXHEI = 256,
    PICKERHEI = 128,
    MAXHEX = '#ffffffff',

    MARKRAD = 4,

    IMGEXT = {'png','jpg','jpeg'},
    PHTEXT = 'pht',
    TMPDIR = 'tmp',
    DEFPATH = '',

    PREVIEWSIZE = 256,
    PBUFFER = 65536,
    PWH = 512,
    PSIZE = 8,
    PEMIT = 4096,
    PTIME = 64,
    PSPEED = 2048,
    PI = math.pi,
    PI2 = math.pi*2,
    PQUAD = 16,

    COLORS = {
    ['text'] = '#afafaf',
    ['window'] = '#2d2d2d',
    ['header'] = '#282828',
    ['border'] = '#414141',
    ['button'] = '#424242',
    ['button hover'] = '#585858',
    ['button active'] = '#232323',
    ['toggle'] = '#646464',
    ['toggle hover'] = '#787878',
    ['toggle cursor'] = '#2d2d2d',
    ['select'] = '#2d2d2d',
    ['select active'] = '#234343',
    ['slider'] = '#262626',
    ['slider cursor'] = '#646464',
    ['slider cursor hover'] = '#787878',
    ['slider cursor active'] = '#969696',
    ['property'] = '#262626',
    ['edit'] = '#262626',
    ['edit cursor'] = '#afafaf',
    ['combo'] = '#2d2d2d',
    ['chart'] = '#787878',
    ['chart color'] = '#2d2d2d',
    ['chart color highlight'] = '#ff0000',
    ['scrollbar'] = '#282828',
    ['scrollbar cursor'] = '#646464',
    ['scrollbar cursor hover'] = '#787878',
    ['scrollbar cursor active'] = '#969696',
    ['tab header'] = '#282828'
    }
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
