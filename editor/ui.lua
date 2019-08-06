-- Tue Aug  6 17:30:49 2019
-- (c) Alexander Veledzimovich

-- ui PHOTON
-- lua<5.3
local utf8 = require('utf8')
local unpack = table.unpack or unpack

local nuklear = require('nuklear')

local set = require('editor/set')

local UI = {}
function UI.editor(nk,PS)
    nk:frameBegin()
    if nk:windowBegin('Code', 0, set.MIDHEI, set.CODEWID, set.CODEHEI,
            'border', 'title', 'movable','minimizable','scrollbar') then
        local _,_,_,hei = nk:windowGetContentRegion()
        nk:layoutRow('dynamic', hei-set.GROUPMARGIN*2, 1)
        if nk:widgetIsHovered() then
            nk:tooltip('Right Click To Copy')
        end
        PS.codeState = nk:edit('box', PS.code)
    end
    nk:windowEnd()

    if nk:windowBegin('Editor', set.MIDWID, 0, set.EDWID, set.EDHEI,
            'border', 'title', 'movable','minimizable') then

        nk:layoutRow('dynamic',set.DOUBHEI + set.GROUPMARGIN * 2, 1)
        nk:groupBegin('Menu','border')
            nk:layoutRow('dynamic',set.DOUBHEI, 5)
            if nk:button('New') then PS.new() end
            if nk:button('Clear') then PS.clear() end
            if nk:button('Import') then PS.import() end
            if nk:button('Export') then PS.export() end
            nk:selectable('Setup',nil,'centered',PS.hotset)
        nk:groupEnd()

        nk:layoutRow('dynamic',set.SINGHEI*8 + set.GROUPMARGIN * 2, 1)
        nk:groupBegin('Menu','border')
            nk:layoutRow('dynamic',set.SINGHEI, {0.2,0.05,0.25,0.25,0.25})
            nk:label('Insert Mode','centered')
            nk:spacing(1)
            nk:radio('top',PS.set.mode)
            nk:radio('bottom',PS.set.mode)
            nk:radio('random',PS.set.mode)

            nk:layoutRow('dynamic',set.SINGHEI, set.SLIDERLAYOUT)
            if nk:button('Buffer') then
                PS.buffer()
            end
            nk:slider(0, PS.set.buffer, set.PBUFFER, 1)
            nk:label(PS.set.buffer.value,'right')

            nk:layoutRow('dynamic',set.SINGHEI, set.SLIDERLAYOUT)
            if nk:button('Emit') then
                PS.emit()
            end
            nk:slider(1, PS.set.emit, set.PEMIT, 1)
            nk:label(PS.set.emit.value,'right')

            nk:layoutRow('dynamic',set.SINGHEI, set.SLIDERLAYOUT)
            if nk:button('Lifetime') then
                PS.lifetime()
            end
            nk:slider(-1, PS.set.lifetime, set.PTIME,1)
            nk:label(PS.set.lifetime.value,'right')

            nk:layoutRow('dynamic', set.DOUBHEI,{0.2,0.3,0.3,0.2})
            if nk:button('Load') then
                PS.loadImd()
            end
            nk:edit('field',PS.set.loadpath)
            if nk:comboboxBegin('Select') then
                nk:layoutRow('dynamic', set.SINGHEI,1)
                nk:radio('none',PS.set.imgdata)
                for k,_ in pairs(PS.imgdata) do
                    nk:layoutRow('dynamic', set.SINGHEI,1)
                    nk:radio(k,PS.set.imgdata)
                end
                nk:comboboxEnd()
            end
            nk:label(PS.set.imgdata.value,'centered')

            nk:layoutRow('dynamic', set.SINGHEI,
                    {0.14,0.15,0.18,0.21,0.19,0.13})
            for i=1,#PS.forms do
                 nk:radio(PS.forms[i], PS.set.form)
            end
        nk:groupEnd()


        local imageData = PS.imgdata[PS.set.imgdata.value]
        local imdwid,imdhei
        if imageData then
            imdwid,imdhei=imageData:getDimensions()
        end

        local oldwid, oldhei
        oldwid = PS.set.wid.value
        oldhei = PS.set.hei.value
        nk:layoutRow('dynamic',set.SINGHEI, 1)
        nk:property('Width', 0, PS.set.wid, set.PWH, 0.1, 1)

        nk:layoutRow('dynamic',set.SINGHEI, 1)
        nk:property('Height', 0, PS.set.hei, set.PWH, 0.1, 1)

        nk:layoutRow('dynamic',set.SINGHEI, 2)
        nk:property('Quad X', 1, PS.set.qCols, set.PQUAD, 1, 1)
        nk:property('Quad Y', 1, PS.set.qRows, set.PQUAD, 1, 1)

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
        nk:layoutRow('dynamic',set.SINGHEI,2)
        nk:property('Offset X', 0, PS.set.offsetX, PS.set.wid.value, 1, 1)
        nk:property('Offset Y', 0, PS.set.offsetY, PS.set.hei.value, 1, 1)

        local colors = #PS.set.color
        nk:layoutRow('dynamic', set.DOUBHEI, colors)
        for i=1,colors do
            local clr = PS.set.color[i]
            local color = nuklear.colorRGBA(clr[1]*255,clr[2]*255,
                                            clr[3]*255,clr[4]*255)
            if nk:comboboxBegin(nil, color) then
                local rgba = {'R',clr[1],'G',clr[2],'B',clr[3],'A',clr[4]}
                for j=1, #rgba,2 do
                    nk:layoutRow('dynamic',set.SINGHEI, {0.1,0.7,0.2})
                    nk:label(rgba[j])
                    rgba[j+1] = PS.round(nk:slider(0, rgba[j+1], 1, 0.01),3)
                    nk:label(rgba[j+1])
                end
                PS.set.color[i]={rgba[2],rgba[4],rgba[6],rgba[8]}
                nk:comboboxEnd()
            end
        end

        nk:layoutRow('dynamic',set.SINGHEI, 1)
        nk:property('Emission Rate', 0, PS.set.rate, set.PEMIT, 1, 10)

        nk:layoutRow('dynamic',set.SINGHEI, 4)
        nk:checkbox('outside', PS.set.areaDir)
        nk:radio('none',PS.set.areaForm)
        nk:radio('uniform',PS.set.areaForm)
        nk:radio('normal',PS.set.areaForm)
        nk:layoutRow('dynamic',set.SINGHEI, 4)
        nk:spacing(1)
        nk:radio('ellipse',PS.set.areaForm)
        nk:radio('borderellipse','sphere',PS.set.areaForm)
        nk:radio('borderrectangle','perimeter',PS.set.areaForm)

        nk:layoutRow('dynamic',set.SINGHEI,2)
        nk:property('Emission Area X', 0, PS.set.areaX, set.VIEWWID, 1, 10)
        nk:property('Emission Area Y', 0, PS.set.areaY, set.VIEWWID, 1, 10)

        nk:layoutRow('dynamic',set.SINGHEI,1)
        nk:property('Emission Area Angle',0, PS.set.areaAng,set.PI2,0.01, 0.1)


        nk:layoutRow('dynamic',set.SINGHEI,2)
        nk:property('Time Min',
                0, PS.set.timeMin, PS.set.timeMax.value, 0.01, 0.1)
        nk:property('Time Max',
                PS.set.timeMin.value, PS.set.timeMax, set.PTIME, 0.01, 0.1)


        nk:layoutRow('dynamic',set.SINGHEI,2)
        nk:property('Size 1', 0, PS.set.size1, set.PSIZE, 0.01, 0.05)
        nk:property('Size 2', 0, PS.set.size2, set.PSIZE, 0.01, 0.05)
        nk:layoutRow('dynamic',set.SINGHEI,2)
        nk:property('Size 3', 0, PS.set.size3, set.PSIZE, 0.01, 0.05)
        nk:property('Size 4', 0, PS.set.size4, set.PSIZE, 0.01, 0.05)
        nk:layoutRow('dynamic',set.SINGHEI,2)
        nk:property('Size 5', 0, PS.set.size5, set.PSIZE, 0.01, 0.05)
        nk:property('Size 6', 0, PS.set.size6, set.PSIZE, 0.01, 0.05)
        nk:layoutRow('dynamic',set.SINGHEI,2)
        nk:property('Size 7', 0, PS.set.size7, set.PSIZE, 0.01, 0.05)
        nk:property('Size 8', 0, PS.set.size8, set.PSIZE, 0.01, 0.05)
        nk:layoutRow('dynamic',set.SINGHEI,1)
        nk:property('Size Variation', 0, PS.set.sizeVar, 1, 0.01, 0.01)

        nk:layoutRow('dynamic',set.SINGHEI,1)
        nk:property('Speed Min',
                0, PS.set.speedMin, set.PSPEED, 1,10)
        nk:layoutRow('dynamic',set.SINGHEI, 1)
        nk:property('Speed Max',
                PS.set.speedMin.value, PS.set.speedMax, set.PSPEED, 1,10)
        nk:layoutRow('dynamic',set.SINGHEI,2)
        nk:property('Acc X Min',
                -set.PSPEED, PS.set.accXMin, set.PSPEED, 1, 10)
        nk:property('Acc X Max',
                PS.set.accXMin.value, PS.set.accXMax,set.PSPEED, 1,10)
        nk:layoutRow('dynamic',set.SINGHEI,2)
        nk:property('Acc Y Min',
                -set.PSPEED, PS.set.accYMin, set.PSPEED, 1,10)
        nk:property('Acc Y Max',
                PS.set.accYMin.value, PS.set.accYMax,set.PSPEED, 1,10)
        nk:layoutRow('dynamic',set.SINGHEI,2)
        nk:property('Rad Acc Min',
                -set.PSPEED, PS.set.radAccMin, set.PSPEED, 1,10)
        nk:property('Rad Y Max',
                PS.set.radAccMin.value, PS.set.radAccMax,set.PSPEED,1,10)
        nk:layoutRow('dynamic',set.SINGHEI,2)
        nk:property('Tang Acc Min',
                -set.PSPEED, PS.set.tanAccMin, set.PSPEED, 1, 10)
        nk:property('Tang Acc Max',
                PS.set.tanAccMin.value, PS.set.tanAccMax,set.PSPEED,1, 10)

        nk:layoutRow('dynamic',set.SINGHEI,2)

        nk:property('Damp Min',
                0, PS.set.dampMin, PS.set.dampMax.value, 0.01,0.01)
        nk:property('Damp Max',
                PS.set.dampMin.value, PS.set.dampMax, 1, 0.01,0.01)

        nk:layoutRow('dynamic',set.SINGHEI,1)
        nk:property('Direction',0, PS.set.dir, set.PI2, 0.01,0.1)
        nk:layoutRow('dynamic',set.SINGHEI,1)
        nk:property('Spread', 0, PS.set.spread, set.PI2, 0.01,0.1)

        nk:layoutRow('dynamic',set.SINGHEI,2)
        nk:property('Spin Min',
                -set.PI2, PS.set.spinMin, set.PI2, 0.01,0.1)
        nk:property('Spin Max',
                PS.set.spinMin.value, PS.set.spinMax,set.PI2, 0.01,0.1)
        nk:layoutRow('dynamic',set.SINGHEI,1)
        nk:property('Spin Variation', 0, PS.set.spinVar, 1, 0.01,0.01)

        nk:layoutRow('dynamic',set.SINGHEI,2)
        nk:property('Rotate Min',
                0, PS.set.rotateMin, set.PI2, 0.01,0.1)
        nk:property('Rotate Max',
                PS.set.rotateMin.value, PS.set.rotateMax,set.PI2, 0.01,0.1)

        nk:layoutRow('dynamic',set.SINGHEI,1)
        nk:selectable('RelativeRotation',nil,'centered',PS.set.relative)
    end
    nk:windowEnd()
    nk:frameEnd()
end

return UI
