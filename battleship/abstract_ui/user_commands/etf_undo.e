note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_UNDO
inherit
	ETF_UNDO_INTERFACE
		redefine undo end
create
	make

feature

	s: STRING
feature -- command
	undo
    	do
			if model.g.history.after then
				model.g.history.back
			end

			if model.g.history.on_item then
				model.g.history.item.undo
				model.g.history.back


				model.s.append ("ok")
			else
				model.s.append("no more to undo")
			end

			etf_cmd_container.on_change.notify ([Current])
    	end

end
