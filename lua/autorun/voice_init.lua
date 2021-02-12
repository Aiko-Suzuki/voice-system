local HearType = {
    [1] = {
        distance = 100,
        name = "small"
    },
    [2] = {
        distance = 250,
        name = "medium"
    },
    [3] = {
        distance = 600,
        name = "large"
    }
}

if SERVER then
    function SetTalkType(ply, talktype)
        ply:ChatPrint(talktype)

        if talktype > table.Count(HearType) then
            talktype = 1
        end

        if talktype <= 0 then
            talktype = table.Count(HearType)
        end

        ply:SetNWInt("TalkType", talktype)
    end

    local Switch = {
        case = function(self, case, ...)
            if (self[case]) then
                self[case](...)
            else
                self.default(...)
            end
        end,
        [KEY_P] = function(ply)
            SetTalkType(ply, ply:GetNWInt("TalkType", 2) + 1)
        end,
        [KEY_O] = function(ply)
            SetTalkType(ply, ply:GetNWInt("TalkType", 2) - 1)
        end,
        default = function() return end
    }

    Switch.__index = Switch

    hook.Add("PlayerButtonDown", "VoiceSystem", function(ply, btn)
        if not IsFirstTimePredicted() then return end
        Switch:case(btn, ply)
    end)

    hook.Add("PlayerCanHearPlayersVoice", "VoiceSystem", function(Listener, talker)
        local TalkType = talker:GetNWInt("TalkType", 2)
        if RADIO and (talker.frequency == listener.frequency and talker:GetActiveWeapon():GetClass() == "dradio") then return true end
        if GDrugz and GDrugz.Phone:InCallWith(listener, talker) then return true end
        if PhoneLib and PhoneLib.IsInCall(ply) then return true end

        return talker:GetPos():DistToSqr(Listener:GetPos()) < (HearType[TalkType].distance * HearType[TalkType].distance)
    end)
elseif CLIENT then
    local TalkPreview = false
    local LastTalkChange = 0

    hook.Add("PlayerButtonDown", "VoiceSystem", function(player, btn)
        if not IsFirstTimePredicted() then return end

        if btn == KEY_P or btn == KEY_O then
            TalkPreview = true
            LastTalkChange = CurTime() + 2
        end
    end)

    hook.Add("PostDrawTranslucentRenderables", "test", function()
        if LastTalkChange <= CurTime() then
            TalkPreview = false
        end

        if TalkPreview then
            render.SetColorMaterial()
            render.DrawWireframeSphere(LocalPlayer():GetPos(), HearType[LocalPlayer():GetNWInt("TalkType", 2)].distance, 600, 600, Color(0, 255, 255, 177), true)
        end
    end)
end