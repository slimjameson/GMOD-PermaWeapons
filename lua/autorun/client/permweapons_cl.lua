-- MADE BY SLIM JAMESON
-- lua/autorun/client/permweapons_cl.lua
net.Receive("PermWeapons_OpenMenu", function()
    local selectedWep = nil
    local weaponButtons = {}

    -- Main frame
    local frame = vgui.Create("DFrame")
    frame:SetSize(400, 540)
    frame:Center()
    frame:MakePopup()
    frame:ShowCloseButton(true)
    frame:SetTitle("Permanent Weapons")
    frame.Paint = function(self, w, h)
        draw.RoundedBox(8, 0,   0, w,   h, Color(0, 0, 0, 180))
        draw.RoundedBoxEx(8, 0,   0, w,  32, Color(30, 30, 30, 220), true, true, false, false)
    end

    -- SteamID entry (moved higher)
    local steamEntry = vgui.Create("DTextEntry", frame)
    steamEntry:Dock(TOP)
    steamEntry:DockMargin(10, 10, 10, 5)
    steamEntry:SetTall(28)
    steamEntry:SetPlaceholderText("Enter SteamID or SteamID64")
    steamEntry.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(50, 50, 50, 200))
        local txt = self:GetValue()
        if txt == "" then
            draw.SimpleText(
                self:GetPlaceholderText(),
                "DermaDefault",
                8, h/2,
                Color(150, 150, 150),
                TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER
            )
        else
            self:DrawTextEntryText(
                Color(240,240,240),
                Color(150,150,150),
                Color(240,240,240)
            )
        end
    end

    -- Search bar for weapons
    local searchEntry = vgui.Create("DTextEntry", frame)
    searchEntry:Dock(TOP)
    searchEntry:DockMargin(10, 0, 10, 10)
    searchEntry:SetTall(28)
    searchEntry:SetPlaceholderText("Search weapons...")
    searchEntry.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(50, 50, 50, 200))
        local txt = self:GetValue()
        if txt == "" then
            draw.SimpleText(
                self:GetPlaceholderText(),
                "DermaDefault",
                8, h/2,
                Color(150, 150, 150),
                TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER
            )
        else
            self:DrawTextEntryText(
                Color(240,240,240),
                Color(150,150,150),
                Color(240,240,240)
            )
        end
    end

    -- Scrollable list of weapon buttons
    local scroll = vgui.Create("DScrollPanel", frame)
    scroll:Dock(FILL)
    scroll:DockMargin(10, 0, 10, 10)
    local canvas = scroll:GetCanvas()

    for _, wep in ipairs(weapons.GetList()) do
        local btn = vgui.Create("DButton", canvas)
        btn:Dock(TOP)
        btn:DockMargin(0, 0, 0, 4)
        btn:SetTall(30)
        btn:SetText("")
        btn.ClassName = wep.ClassName

        btn.Paint = function(self, w, h)
            local bg = Color(60, 60, 90, 200)
            if selectedWep == self.ClassName then
                bg = Color(80, 80, 130, 220)
            elseif self:IsHovered() then
                bg = Color(70, 70, 110, 220)
            end
            draw.RoundedBox(4, 0, 0, w, h, bg)
            draw.SimpleText(
                self.ClassName,
                "DermaDefault",
                10, h/2,
                color_white,
                TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER
            )
        end

        btn.DoClick = function()
            if selectedWep == btn.ClassName then
                selectedWep = nil
            else
                selectedWep = btn.ClassName
            end
        end

        table.insert(weaponButtons, btn)
    end

    -- Filter logic
    searchEntry.OnValueChange = function(self, val)
        local filter = val:lower()
        for _, btn in ipairs(weaponButtons) do
            btn:SetVisible(filter == "" or btn.ClassName:lower():find(filter, 1, true))
        end
        canvas:InvalidateLayout(true)
    end

    -- Save button
    local saveText = "Save Permanent Weapon"
    local save = vgui.Create("DButton", frame)
    save:Dock(BOTTOM)
    save:DockMargin(10, 0, 10, 10)
    save:SetTall(40)
    save:SetText("")

    save.Paint = function(self, w, h)
        local bg = self:IsHovered() and Color(90, 90, 140) or Color(70, 70, 120)
        draw.RoundedBox(4, 0, 0, w, h, bg)
        draw.SimpleText(
            saveText,
            "DermaDefaultBold",
            w/2, h/2 - 1,
            color_white,
            TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER
        )
    end

    save.DoClick = function()
        local sid = steamEntry:GetValue():Trim()
        if sid == "" then
            chat.AddText(Color(200,50,50), "→ Please enter a SteamID (DONT USE STEAMID64).")
            return
        end
        if not selectedWep then
            chat.AddText(Color(200,50,50), "→ Please select a weapon.")
            return
        end

        net.Start("PermWeapons_Apply")
        net.WriteString(sid)
        net.WriteString(selectedWep)
        net.SendToServer()
        frame:Close()
    end
end)