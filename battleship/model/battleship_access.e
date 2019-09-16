note
	description: "Singleton access to the default business model."
	author: "Jackie Wang"
	date: "$Date$"
	revision: "$Revision$"

expanded class
	BATTLESHIP_ACCESS

feature
	m: BATTLESHIP
		once
			create Result.make
		end

invariant
	m = m
end




