function CheckMaxChar(userId)
	local userMaxChar = MySQL.single.await('SELECT `charLimit` FROM `users` WHERE `identifier` = ? LIMIT 1', { userId })
	if not userMaxChar then return false end

	return userMaxChar.charLimit
end

exports('CheckMaxChar', CheckMaxChar)
