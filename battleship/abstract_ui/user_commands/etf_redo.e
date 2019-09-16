note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_REDO
inherit
	ETF_REDO_INTERFACE
		redefine redo end
create
	make

feature

	s : STRING
feature -- command
	redo
    	do
			-- forth
			if
				model.g.history.before
				or not model.g.history.after
			then
				model.g.history.forth
			end

			-- redo
			if model.g.history.on_item then
				model.g.history.item.redo
				model.s.append ("ok")
			else
				model.s.append ("nothing to redo")
			end

			-- push
			etf_cmd_container.on_change.notify ([Current])
    	end

end
