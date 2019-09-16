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
    local PH = PS.photons[PS.systems.value]
    nk:frameBegin()
    if nk:windowBegin('Code', 0, set.MIDHEI, set.CODEWID, set.CODEHEI,
            'border', 'title', 'movable','minimizable','scrollbar') then
        local _,_,_,hei = nk:windowGetContentRegion()
        if PH then
            nk:layoutRow('dynamic', hei-set.GROUPMARGIN*2, 1)
            if nk:widgetIsHovered() then
                nk:tooltip('Right Click To Copy')
            end
            PS.codestate = nk:edit('box', PH.code)
        end
    end
    nk:windowEnd()

    if nk:windowBegin('Editor', set.MIDWID, 0, set.EDWID, set.EDHEI,
            'border', 'title', 'movable','minimizable') then

        nk:layoutRow('dynamic',set.DOUBHEI+set.GROUPMARGIN*2, 1)
        nk:groupBegin('Menu','border')
            nk:layoutRow('dynamic',set.DOUBHEI,5)
            if nk:button('New') then PS.new() end
            if nk:button('Clone') then PS.clone() end
            if nk:button('Export') then  PS.export() end
            nk:edit('simple',PH and PH.set.pname or {value='name'})

            nk:styleLoadColors(set.COLORS)
            if nk:button('Delete') then PS.delete() end
            nk:styleDefault()
        nk:groupEnd()

    if PH then
        nk:layoutRow('dynamic',set.SINGHEI+set.GROUPMARGIN*2, 1)
        nk:groupBegin('Control','border')
            nk:layoutRow('dynamic',set.SINGHEI, 7)
            if nk:button('Start') then PH:start() end
            if nk:button('Pause') then PH:pause() end
            if nk:button('Stop') then  PH:stop() end
            if nk:button('Reset') then PH:reset() end
            nk:styleLoadColors(set.COLORS)
            nk:selectable('Setup',nil,'centered',PS.hotset)
            nk:combobox(PS.systems,PS.systems.items)
            nk:selectable('Marks', nil, 'centered',PS.marks)
            nk:styleDefault()
        nk:groupEnd()


        nk:layoutRow('dynamic',set.SINGHEI+set.GROUPMARGIN*2, 1)
        nk:groupBegin('Emit','border')
            nk:layoutRow('dynamic',set.SINGHEI, {0.2,0.5,0.1,0.05,0.15})
            if nk:button('Emit') then
                PH:emit()
            end
            nk:slider(1, PH.set.emit, set.PEMIT, 1)
            nk:label(PH.set.emit.value,'left')
            nk:label('E','right')
            nk:label(PH.count,'right')
        nk:groupEnd()


        nk:layoutRow('dynamic',set.SINGHEI*3+set.GROUPMARGIN*4, 1)
        nk:groupBegin('Buffer','border')
            nk:layoutRow('dynamic',set.SINGHEI, {0.2,0.05,0.25,0.25,0.25})
            nk:label('Insert Mode')
            nk:spacing(1)
            nk:radio('top',PH.set.mode)
            nk:radio('bottom',PH.set.mode)
            nk:radio('random',PH.set.mode)

            nk:layoutRow('dynamic',set.SINGHEI, 1)
            nk:property('Buffer', 1, PH.set.buffer, set.PBUFFER, 10, 100)

            nk:layoutRow('dynamic',set.SINGHEI, 1)
            nk:property('Lifetime', -1, PH.set.lifetime, set.PTIME, 1, 1)
        nk:groupEnd()


        nk:layoutRow('dynamic',set.SINGHEI*5+set.GROUPMARGIN*5, 1)
        nk:groupBegin('Area','border')
            nk:layoutRow('dynamic',set.SINGHEI, 1)
            nk:property('Emission Rate', 0, PH.set.rate, set.PEMIT, 1, 10)


            nk:layoutRow('dynamic',set.SINGHEI, 4)
            nk:checkbox('outside', PH.set.areaDir)
            nk:radio('none',PH.set.areaForm)
            nk:radio('uniform',PH.set.areaForm)
            nk:radio('normal',PH.set.areaForm)
            nk:layoutRow('dynamic',set.SINGHEI, 4)
            nk:checkbox('relative',PH.set.relative)
            nk:radio('ellipse',PH.set.areaForm)
            nk:radio('borderellipse','sphere',PH.set.areaForm)
            nk:radio('borderrectangle','perimeter',PH.set.areaForm)

            nk:layoutRow('dynamic',set.SINGHEI,2)
            nk:property('Emission Area X', 0, PH.set.areaX, set.VIEWWID, 1, 10)
            nk:property('Emission Area Y', 0, PH.set.areaY, set.VIEWWID, 1, 10)

            nk:layoutRow('dynamic',set.SINGHEI,1)
            nk:property('Emission Area Angle',
                0, PH.set.areaAng,set.PI2, 0.01, 0.1)
        nk:groupEnd()


        local oldform = PH.set.form.value
        nk:layoutRow('dynamic',set.DOUBHEI+set.GROUPMARGIN*2, 1)
        nk:groupBegin('Texture','border')
            nk:layoutRow('dynamic', set.DOUBHEI,{0.2,0.6,0.2})
            nk:label('Texture','left')
            if nk:comboboxBegin('Select') then
                nk:layoutRow('dynamic', set.SINGHEI,1)
                for i=1,#PH.forms do
                    nk:radio(PH.forms[i], PH.set.form)
                end
                for k,_ in pairs(PS.imgbase) do
                    nk:layoutRow('dynamic', set.SINGHEI,1)
                    nk:radio(k,PH.set.form)
                end
                nk:comboboxEnd()
            end
            nk:label(PH.set.form.value,'centered')
        nk:groupEnd()

        if PH.set.form.value ~= oldform then
            PH:setImageData()
        end
        local imagedata = PS.imgbase[PH.set.form.value]
        local imdwid,imdhei
        if imagedata then
            imdwid,imdhei = imagedata:getDimensions()
        end

        local oldwid, oldhei
        oldwid = PH.set.wid.value
        oldhei = PH.set.hei.value
        nk:layoutRow('dynamic',set.SINGHEI, 1)
        nk:property('Width', 1, PH.set.wid, set.PWH, 0.1, 1)
        nk:layoutRow('dynamic',set.SINGHEI, 1)
        nk:property('Height', 1, PH.set.hei, set.PWH, 0.1, 1)

        nk:layoutRow('dynamic',set.SINGHEI, 2)
        nk:property('Quad X', 1, PH.set.qCols, set.PQUAD, 1, 1)
        nk:property('Quad Y', 1, PH.set.qRows, set.PQUAD, 1, 1)

        if imagedata then
            PH.set.wid.value = imdwid/PH.set.qCols.value
            PH.set.hei.value = imdhei/PH.set.qRows.value
        end

        if oldwid ~= PH.set.wid.value then
            PH.set.offsetX.value = PH.set.wid.value/2
            PH:setImageData()
        end
        if oldhei ~= PH.set.hei.value then
            PH.set.offsetY.value = PH.set.hei.value/2
            PH:setImageData()
        end
        nk:layoutRow('dynamic',set.SINGHEI,2)
        nk:property('Offset X', 0, PH.set.offsetX, PH.set.wid.value, 1, 1)
        nk:property('Offset Y', 0, PH.set.offsetY, PH.set.hei.value, 1, 1)

        local rowclr = #PH.set.color/4
        nk:layoutRow('dynamic', set.COLORHEI, rowclr/4)
        UI.layoutColors(nk,PH,1,rowclr)
        nk:layoutRow('dynamic', set.COLORHEI, rowclr/4)
        UI.layoutColors(nk,PH,rowclr+1, #PH.set.color)

        nk:layoutRow('dynamic',set.SINGHEI,2)
        nk:property('Time Min',
                0, PH.set.timeMin, PH.set.timeMax.value, 0.01, 0.1)
        nk:property('Time Max',
                PH.set.timeMin.value, PH.set.timeMax, set.PTIME, 0.01, 0.1)

        nk:layoutRow('dynamic',set.SINGHEI,2)
        nk:property('Size 1', 0, PH.set.size1, set.PSIZE, 0.01, 0.1)
        nk:property('Size 2', 0, PH.set.size2, set.PSIZE, 0.01, 0.1)
        nk:layoutRow('dynamic',set.SINGHEI,2)
        nk:property('Size 3', 0, PH.set.size3, set.PSIZE, 0.01, 0.1)
        nk:property('Size 4', 0, PH.set.size4, set.PSIZE, 0.01, 0.1)
        nk:layoutRow('dynamic',set.SINGHEI,2)
        nk:property('Size 5', 0, PH.set.size5, set.PSIZE, 0.01, 0.1)
        nk:property('Size 6', 0, PH.set.size6, set.PSIZE, 0.01, 0.1)
        nk:layoutRow('dynamic',set.SINGHEI,2)
        nk:property('Size 7', 0, PH.set.size7, set.PSIZE, 0.01, 0.1)
        nk:property('Size 8', 0, PH.set.size8, set.PSIZE, 0.01, 0.1)
        nk:layoutRow('dynamic',set.SINGHEI,1)
        nk:property('Size Variation', 0, PH.set.sizeVar, 1, 0.01, 0.01)

        nk:layoutRow('dynamic',set.SINGHEI,2)
        nk:property('Speed Min',
                0, PH.set.speedMin, PH.set.speedMax.value, 1,10)
        nk:property('Speed Max',
                PH.set.speedMin.value, PH.set.speedMax, set.PSPEED, 1,10)
        nk:layoutRow('dynamic',set.SINGHEI,2)
        nk:property('Acc X Min',
                -set.PSPEED, PH.set.accXMin, PH.set.accXMax.value, 1, 10)
        nk:property('Acc X Max',
                PH.set.accXMin.value, PH.set.accXMax,set.PSPEED, 1,10)
        nk:layoutRow('dynamic',set.SINGHEI,2)
        nk:property('Acc Y Min',
                -set.PSPEED, PH.set.accYMin, PH.set.accYMax.value, 1,10)
        nk:property('Acc Y Max',
                PH.set.accYMin.value, PH.set.accYMax,set.PSPEED, 1,10)
        nk:layoutRow('dynamic',set.SINGHEI,2)
        nk:property('Rad Acc Min',
                -set.PSPEED, PH.set.radAccMin, PH.set.radAccMax.value, 1,10)
        nk:property('Rad Acc Max',
                PH.set.radAccMin.value, PH.set.radAccMax,set.PSPEED,1,10)
        nk:layoutRow('dynamic',set.SINGHEI,2)
        nk:property('Tang Acc Min',
                -set.PSPEED, PH.set.tanAccMin, PH.set.tanAccMax.value, 1, 10)
        nk:property('Tang Acc Max',
                PH.set.tanAccMin.value, PH.set.tanAccMax,set.PSPEED,1, 10)
        nk:layoutRow('dynamic',set.SINGHEI,2)
        nk:property('Damp Min',
                0, PH.set.dampMin, PH.set.dampMax.value, 0.01,0.01)
        nk:property('Damp Max',
                PH.set.dampMin.value, PH.set.dampMax, 1, 0.01,0.01)

        nk:layoutRow('dynamic',set.SINGHEI,2)
        nk:property('Direction',0, PH.set.dir, set.PI2, 0.01,0.1)
        nk:property('Spread', 0, PH.set.spread, set.PI2, 0.01,0.1)

        nk:layoutRow('dynamic',set.SINGHEI,2)
        nk:property('Spin Min',
                -set.PI2, PH.set.spinMin, PH.set.spinMax.value, 0.01,0.1)
        nk:property('Spin Max',
                PH.set.spinMin.value, PH.set.spinMax,set.PI2, 0.01,0.1)
        nk:layoutRow('dynamic',set.SINGHEI,1)
        nk:property('Spin Variation', 0, PH.set.spinVar, 1, 0.01,0.01)
        nk:layoutRow('dynamic',set.SINGHEI,2)
        nk:property('Rotate Min',0, PH.set.rotateMin,
                PH.set.rotateMax.value, 0.01,0.1)
        nk:property('Rotate Max',
                PH.set.rotateMin.value, PH.set.rotateMax,set.PI2, 0.01,0.1)
    end
    end
    nk:windowEnd()
    nk:frameEnd()
end

function UI.layoutColors(nk,PH,st,fin)
    for i=st,fin,4 do
        local clr = PH.set.color
        local color = nuklear.colorRGBA(clr[i]*255,clr[i+1]*255,
                                        clr[i+2]*255,clr[i+3]*255)
        if nk:comboboxBegin(nil, color) then
            local rgba = {'R',clr[i],'G',clr[i+1],'B',clr[i+2],'A',clr[i+3]}
            for j=1, #rgba,2 do
                nk:layoutRow('dynamic',set.SINGHEI, 1)
                rgba[j+1] = nk:property(rgba[j],0, rgba[j+1], 1, 0.01, 0.01)
            end
            PH.set.color[i] = rgba[2]
            PH.set.color[i+1] = rgba[4]
            PH.set.color[i+2] = rgba[6]
            PH.set.color[i+3] = rgba[8]
            nk:comboboxEnd()
        end
    end
end

return UI
