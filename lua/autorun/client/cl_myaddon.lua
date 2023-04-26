include("autorun/sh_myaddon.lua")

surface.CreateFont( "myaddon_sb_14", {
    font = "Roboto",
    extended = false,
    size = 14,
    weight = 500,
} )

surface.CreateFont( "myaddon_sb_24", {
    font = "Roboto",
    extended = false,
    size = 24,
    weight = 500,
} )

hook.Add("HUDPaint", "MyAddonHUD", function()
    local scrw,scrh = ScrW(), ScrH()
    local ply = LocalPlayer()
    local hp = ply:Health()
    local maxhp = ply:GetMaxHealth()
    local boxW, boxH = scrw * .1, scrh * .02
    surface.SetDrawColor(0, 0, 0, 200)
    surface.DrawRect(scrw / 2 - boxW / 2, scrh - boxH * 1.1, boxW, boxH)
    surface.SetDrawColor(255, 0, 0, 200)
    surface.DrawRect(scrw / 2 - boxW / 2, scrh - boxH * 1.1, boxW * (hp / maxhp), boxH)

    surface.SetDrawColor(0, 0, 0, 200)
    surface.DrawRect(scrw * .2, scrh * .05, scrw * .6, scrh * .05)
    draw.SimpleText(MYADDON_DISPLAYMESSAGE, "myaddon_sb_24", scrw / 2, scrh * .075, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end)

local function ToggleScoreboard(toggle)
    if toggle then
        local scrw,scrh = ScrW(), ScrH()
        MyAddonScoreboard = vgui.Create("DFrame")
        MyAddonScoreboard:SetTitle("")
        MyAddonScoreboard:SetSize(scrw * .3, scrh * .6)
        MyAddonScoreboard:Center()
        MyAddonScoreboard:MakePopup()
        MyAddonScoreboard:ShowCloseButton(false)
        MyAddonScoreboard:SetDraggable(false)
        MyAddonScoreboard.Paint = function(self, w, h)
            surface.SetDrawColor(0,0,0,200)
            surface.DrawRect(0, 0, w, h)
            draw.SimpleText("Scoreboard", "myaddon_sb_14", w / 2, h * .02, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        local scroll = vgui.Create("DScrollPanel", MyAddonScoreboard)
        scroll:SetSize(MyAddonScoreboard:GetWide(), MyAddonScoreboard:GetTall() * .97)
        local ypos = 0
        scroll:SetPos(0, MyAddonScoreboard:GetTall() * .03)
        for k, v in pairs(player.GetAll()) do
            local playerPanel = vgui.Create("DPanel", scroll)
            playerPanel:SetPos(0, ypos)
            playerPanel:SetSize(MyAddonScoreboard:GetWide(), MyAddonScoreboard:GetTall() * .05)
            local name = v:Name()
            local ping = v:Ping()
            playerPanel.Paint = function(self, w, h)
                if IsValid(v) then
                    surface.SetDrawColor(0, 0, 0, 200)
                    surface.DrawRect(0, 0, w, h)
                    draw.SimpleText(name .. " Ping: " .. ping, "myaddon_sb_14", w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end
            end
            ypos = ypos + playerPanel:GetTall() * 1.1
        end
    else
        if IsValid(MyAddonScoreboard) then
            MyAddonScoreboard:Remove()
        end
    end
end

hook.Add("ScoreboardShow", "MyAddonOpenScoreboard", function()
    ToggleScoreboard(true)
    net.Start("scoreboard_opened")
    net.SendToServer()
    return false
end)

hook.Add("ScoreboardHide", "MyAddonCloseScoreboard", function()
    ToggleScoreboard(false)
end)

net.Receive("displaymessage_update", function()
    local newMessage = net.ReadString()
    MYADDON_DISPLAYMESSAGE = newMessage
end)

local dist = 4000^2
hook.Add("HUDPaint", "WaypointExample", function()
    for k,v in pairs(player.GetAll()) do
        if v == LocalPlayer() then continue end
        local pos = v:GetPos()
        if LocalPlayer():GetPos():DistToSqr(pos) < dist then
            pos = pos:ToScreen()
            surface.SetDrawColor(0, 0, 0, 200)
            surface.DrawRect(pos.x - 32, pos.y - 32, 64, 64)
            draw.SimpleText(v:Name(), "myaddon_sb_14", pos.x, pos.y, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end
end)