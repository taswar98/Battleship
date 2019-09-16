note
	description: "Summary description for {OPERATION}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	OPERATION
feature
--	state: BATTLESHIP
--		local
--			ba: BATTLESHIP_ACCESS
--		once
--			Result := ba.game.state
--		end

--	game: GAME
--		local
--			ga: BATTLESHIP_ACCESS
--		once
--			Result := ga.game
--		end

	battleship: BATTLESHIP
	local
		ba: BATTLESHIP_ACCESS
	once
		Result := ba.m
	 end

	item: STRING


	execute
		deferred
		end
	undo
		deferred
		end

	redo
		deferred
		end

end
