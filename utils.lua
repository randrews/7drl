module(..., package.seeall)

CURRENT_DIALOG = nil

function dialog(title, text, button1_text, button2_text)
    local promise = Promise()
    
    local dialog = loveframes.Create('frame')
    dialog:SetSize(200, 120)
    dialog:Center()
    dialog:SetName(title)
    dialog:SetModal(true)
    dialog:ShowCloseButton(false)

    local white = {255, 255, 255}
    local label = loveframes.Create('text', dialog)
    label:SetText{white, "Really quit?"}
    label:Center()
    label:SetY(50)

    local btn1 = loveframes.Create('button', dialog)
    btn1:SetText(button1_text or 'Yes')
    btn1:SetSize(85, 20)
    btn1:SetPos(10, 90)

    local btn2 = loveframes.Create('button', dialog)
    btn2:SetText(button2_text or 'No')
    btn2:SetSize(85, 20)
    btn2:SetPos(105, 90)

    local function finished(btn)
        local str = btn:GetText()
        dialog:Remove()
        CURRENT_DIALOG = nil
        promise:finish(str)
    end

    btn1.OnClick = finished
    btn2.OnClick = finished

    CURRENT_DIALOG = {dialog = dialog, btn1 = btn1, btn2 = btn2}

    return promise
end

function capture_input() return CURRENT_DIALOG end

function keypressed(key)
    if CURRENT_DIALOG then
        if key == 'return' then CURRENT_DIALOG.btn1:OnClick()
        elseif key == 'escape' then CURRENT_DIALOG.btn2:OnClick() end
    end
end