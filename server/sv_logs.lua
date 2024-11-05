--------------------------------------------------------------------------------------------------------------------
--------------------------------------------------- DISCORD --------------------------------------------------------


function GetIdentity(source, identity)
    local num = 0
    if not source then return end
    
    local num2 = GetNumPlayerIdentifiers(source)

    if GetNumPlayerIdentifiers(source) > 0 then
        local ident = nil
        while num < num2 and not ident do
            local a = GetPlayerIdentifier(source, num)
            if string.find(a, identity) then ident = a end
            num = num + 1
        end
        --return ident;
        if ident == nil then
            return ""
        end
        return string.sub(ident, 9)
    end
end

RegisterServerEvent('vorp_core:addWebhook')
AddEventHandler('vorp_core:addWebhook', function(title, webhook, description, color, name, logo, footerlogo, avatar)
    if not webhook or webhook == "" then
        return
    end
    local webhookColor = (not color or color == "") and Config.webhookColor or color
    local webhookName = (not name or name == "") and Config.name or name
    local webhookLogo = (not logo or logo == "") and Config.logo or logo
    local webhookFooterLogo = (not footerlogo or footerlogo == "") and Config.footerLogo or footerlogo
    local webhookAvatar = (not avatar or avatar == "") and Config.Avatar or avatar

    PerformHttpRequest(webhook, function(err, text, headers)

    end, 'POST', json.encode({
        embeds = {
            {
                color = webhookColor,
                author = {
                    name = webhookName,
                    icon_url = webhookLogo,
                },
                title = title,
                description = description,
                footer = {
                    text = "VORPcore" .. " • " .. os.date("%x %X %p"),
                    icon_url = webhookFooterLogo,

                },
            },
        },
        avatar_url = webhookAvatar
    }), {
        ['Content-Type'] = 'application/json'
    })
end)
