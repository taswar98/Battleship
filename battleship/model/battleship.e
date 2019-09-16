note
	description: "A default business model."
	author: "Jackie Wang"
	date: "$Date$"
	revision: "$Revision$"

class
	BATTLESHIP

inherit
	ANY
		redefine
			out
		end

create {BATTLESHIP_ACCESS}
	make

feature {NONE} -- Initialization
	make
			-- Initialization for `Current'.
		local
			dummy: INTEGER_64
		do
			row_indices := <<'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L'>>
			create shots.default_create
			create bombs.default_create
			create score.default_create
			create total.default_create
			create ships.default_create
			create ships_status.make_empty
			create output_message.make_empty
			create message.make_empty
			create history.make
			-- Initialy 'advanced' mode
			create g.make_empty
		--	create history.make
			ships_list := g.generate_ships (false, g.board.height, 2)
--			place_new_ships (g.board, ships_list)
--			dummy := 16
--			construct (dummy)
			shots := [0, 1]
			bombs := [0, 1]
			score := [0, 1]
			ships := [0, 1]



			s := "Start a new game"
			state_message := "OK"
			model_state := 0
			current_game := 0
			playing := False
			debug_mode := False
			never_started := True
			never_attacked := True
		end


feature -- model attributes
	g : GAME
	ships_list: ARRAYED_LIST[TUPLE[size: INTEGER; row: INTEGER; col: INTEGER; dir: BOOLEAN]]
	s, state_message,output_message : STRING
	model_state : INTEGER
	playing, debug_mode, never_started, never_attacked : BOOLEAN
	-- status
	current_game : INTEGER
	shots, bombs, score, total, ships : TUPLE[current_value: INTEGER; out_of: INTEGER]
	ships_status : ARRAY[BOOLEAN]
	row_indices : ARRAY[CHARACTER]
	history: HISTORY


feature -- model operations
	default_update
			-- Perform update to the model state.
		do
			model_state := model_state + 1
		end

--	new_game_update
--		do
--			s := s + "Start a new game"
--		end	

	new_game_update(level: INTEGER_64)
		do
			if playing then
				state_message := "Game already started"
				if never_attacked then
					s := "Fire Away!"
				else
					s := "Keep Firing!"
				end
			else
				debug_mode := False
				construct(level)
			end
		end

	debug_test_update(level: INTEGER_64)
		do
			if playing then
				state_message := "Game already started"
				if never_attacked then
					s := "Fire Away!"
				else
					s := "Keep Firing!"
				end
			else
				debug_mode := True
				construct(level)
			end
		end

	fire_update(coordinate: TUPLE[row: INTEGER_64; column: INTEGER_64])
		local
			attack_status: ARRAY[BOOLEAN]
			index: INTEGER
			game_end: BOOLEAN
			c: CHARACTER
		do
			if not playing then
				state_message := "Game not started"
				s := "Start a new game"
			elseif shots.current_value ~ shots.out_of then
				state_message := "No shots remaining"
				s := "Keep Firing!"
			elseif coordinate.row * coordinate.row > g.board.upper.as_integer_64 or coordinate.column * coordinate.column > g.board.upper.as_integer_64 then
				state_message := "Invalid coordinate"
				if never_attacked then
					s := "Fire Away!"
				else
					s := "Keep Firing!"
				end
			else
				never_attacked := False
				c := g.board[coordinate.row.as_integer_32, coordinate.column.as_integer_32].item
				if c ~ 'X' or c ~'O' then
					state_message := "Already fired there"
					s := "Keep Firing!"
				else
					state_message := "OK"
					game_end := True
					attack_status := ships_status
					if attack(coordinate) then
						s := "Hit!"
					else
						s := "Miss!"
					end
					index := ship_status_update(attack_status)
					if index > 0 then
						s := ships_list.array_at (index - 1).size.out + "x1 ship sunk!"
						score.put (score.current_value + ships_list.array_at (index - 1).size, 1)
						total.put (total.current_value + ships_list.array_at (index - 1).size, 1)
						ships.put (ships.current_value + 1, 1)
					end
					shots.put (shots.current_value + 1, 1)
					across ships_status as b loop
						game_end := game_end and b.item
					end
					if game_end then
						s.append (" You Win!")
						playing := False
					elseif shots.current_value = shots.out_of and bombs.current_value = bombs.out_of then
						s.append (" Game Over!")
						playing := False
					else
						s.append (" Keep Firing!")
					end
				end
			end
		end

	bomb_update(coordinate1: TUPLE[row: INTEGER_64; column: INTEGER_64] ; coordinate2: TUPLE[row: INTEGER_64; column: INTEGER_64])
		local
			attack_status: ARRAY[BOOLEAN]
			index1, index2, difference1, difference2: INTEGER
			game_end, b1, b2: BOOLEAN
		do
			if not playing then
				state_message := "Game not started"
				s := "Start a new game"
			elseif bombs.current_value ~ bombs.out_of then
				state_message := "No bombs remaining"
				s := "Keep Firing!"
			else
				difference1 := coordinate1.row.as_integer_32 - coordinate2.row.as_integer_32
				difference1 := difference1.abs
				difference2 := coordinate1.column.as_integer_32 - coordinate2.column.as_integer_32
				difference2 := difference2.abs

				if difference1 > 1 or difference2 > 1 or (difference1 ~ 0 and difference2 ~ 0) or (difference1 ~ 1 and difference2 ~ 1) then
					state_message := "Bomb coordinates must be adjacent"
					if never_attacked then
						s := "Fire Away!"
					else
						s := "Keep Firing!"
					end
				elseif coordinate1.row * coordinate1.row > g.board.upper.as_integer_64 or coordinate1.column * coordinate1.column > g.board.upper.as_integer_64 or coordinate2.row * coordinate2.row > g.board.upper.as_integer_64 or coordinate2.column * coordinate2.column > g.board.upper.as_integer_64 then
					state_message := "Invalid coordinate"
					if never_attacked then
						s := "Fire Away!"
					else
						s := "Keep Firing!"
					end
				elseif g.board[coordinate1.row.as_integer_32, coordinate1.column.as_integer_32].item ~ 'X' or g.board[coordinate1.row.as_integer_32, coordinate1.column.as_integer_32].item ~'O' or g.board[coordinate2.row.as_integer_32, coordinate2.column.as_integer_32].item ~ 'X' or g.board[coordinate2.row.as_integer_32, coordinate2.column.as_integer_32].item ~'O' then
					state_message := "Already fired there"
					s := "Keep Firing!"
				else
					never_attacked := False
					state_message := "OK"
					game_end := True
					attack_status := ships_status
					b1 := attack(coordinate1)
					index1 := ship_status_update(attack_status)
					if index1 > 0 then
						s := ships_list.array_at (index1 - 1).size.out + "x1 ship sunk!"
						score.put (score.current_value + ships_list.array_at (index1 - 1).size, 1)
						total.put (total.current_value + ships_list.array_at (index1 - 1).size, 1)
						ships.put (ships.current_value + 1, 1)
					end

					b2 := attack(coordinate2)
					index2 := ship_status_update(attack_status)
					if index2 > 0 then
						score.put (score.current_value + ships_list.array_at (index2 - 1).size, 1)
						total.put (total.current_value + ships_list.array_at (index2 - 1).size, 1)
						ships.put (ships.current_value + 1, 1)
						if index1 ~ 0 then
							s := ships_list.array_at (index2 - 1).size.out + "x1 ship sunk!"
						elseif index2 > index1 then
							s := (ships_list.array_at (index1 - 1).size.out + "x1 and " + ships_list.array_at (index2 - 1).size.out + "x1 ships sunk!")
						else
							s := (ships_list.array_at (index2 - 1).size.out + "x1 and " + ships_list.array_at (index1 - 1).size.out + "x1 ships sunk!")
						end
					end
					if (b1 or b2) and (index1 ~ 0 and index2 ~ 0) then
						s := "Hit!"
					elseif not b1 and not b2 then
						s := "Miss!"
					end
					bombs.put (bombs.current_value + 1, 1)
					across ships_status as bb loop
						game_end := game_end and bb.item
					end
					if game_end then
						s.append (" You Win!")
						playing := False
					elseif shots.current_value = shots.out_of and bombs.current_value = bombs.out_of then
						s.append (" Game Over!")
						playing := False
					else
						s.append (" Keep Firing!")
					end
				end
			end
		end

	reset
			-- Reset model state.
		do
			make
		end

	construct(level: INTEGER_64)
		local
			values: TUPLE[shot: INTEGER; bomb: INTEGER; ship: INTEGER; scores: INTEGER]
		do
			inspect level
			when 13 then
				g.make_easy
				ships_list := g.generate_ships (debug_mode, g.board.height, 2)
				place_new_ships (g.board, ships_list)
				ships_status.make_filled (False, 1, 2)
				values := [8, 2, 2, 3]
			when 14 then
				g.make_medium
				ships_list := g.generate_ships (debug_mode, g.board.height, 3)
				place_new_ships (g.board, ships_list)
				ships_status.make_filled (False, 1, 3)
				values := [16, 3, 3, 6]
			when 15 then
				g.make_hard
				ships_list := g.generate_ships (debug_mode, g.board.height, 5)
				place_new_ships (g.board, ships_list)
				ships_status.make_filled (False, 1, 5)
				values := [24, 5, 5, 15]
			when 16 then
				g.make_advanced
				ships_list := g.generate_ships (debug_mode, g.board.height, 7)
				place_new_ships (g.board, ships_list)
				ships_status.make_filled (False, 1, 7)
				values := [40, 7, 7, 28]
			else
				model_state := model_state + 999999
				values := [0, 0, 0, 0]
			end
			shots := [0, values.shot]
			bombs := [0, values.bomb]
			score := [0, values.scores]
			ships := [0, values.ship]
			if current_game > 0 and debug_mode then
				total := [total.current_value, total.out_of + values.scores]
			else
				total := [score.current_value, score.out_of]
			end
			if debug_mode then
				current_game := current_game + 1
			else
				current_game := 1
			end
			playing := True
			state_message := "OK"
			s := "Fire Away!"
			never_started := False
		end

	place_new_ships(board: ARRAY2[SHIP_ALPHABET]; new_ships: ARRAYED_LIST[TUPLE[size: INTEGER; row: INTEGER; col: INTEGER; dir: BOOLEAN]])
			-- Place the randomly generated positions of `new_ships' onto the `board'.
			-- Notice that when a ship's row and column are given,
			-- its coordinate starts with (row + 1, col) for a vertical ship,
			-- and starts with (row, col + 1) for a horizontal ship.
		require
			across new_ships.lower |..| new_ships.upper as i all
			across new_ships.lower |..| new_ships.upper as j all
				i.item /= j.item implies not g.collide_with_each_other (new_ships[i.item], new_ships[j.item])
			end
			end
		do
			across
				new_ships as new_ship
			loop
				if new_ship.item.dir then
					-- Vertical ship
					across
						1 |..| new_ship.item.size as i
					loop
						board[new_ship.item.row + i.item, new_ship.item.col] := create {SHIP_ALPHABET}.make ('v')
					end
				else
					-- Horizontal ship
					across
						1 |..| new_ship.item.size as i
					loop
						board[new_ship.item.row, new_ship.item.col + i.item] := create {SHIP_ALPHABET}.make ('h')
					end
				end
			end
		end


feature -- message

	message : STRING

	set_message(a_message: STRING)
		do
			message := a_message
		end


feature -- queries
	attack(coordinate: TUPLE[row: INTEGER_64; column: INTEGER_64]) : BOOLEAN
		local
			new_ship: TUPLE[size: INTEGER; row: INTEGER; col: INTEGER; dir: BOOLEAN]
		do
			new_ship := [1, coordinate.row.as_integer_32, coordinate.column.as_integer_32 - 1, false]
			if g.collide_with (ships_list, new_ship) then
				g.board[coordinate.row.as_integer_32, coordinate.column.as_integer_32] := create {SHIP_ALPHABET}.make ('X')
				Result := True
			else
				g.board[coordinate.row.as_integer_32, coordinate.column.as_integer_32] := create {SHIP_ALPHABET}.make ('O')
				Result := False
			end
		end

	ship_status_update(before : ARRAY[BOOLEAN]) : INTEGER
		local
			ships_status_before : ARRAY[BOOLEAN]
			index: INTEGER
			b, b2: BOOLEAN
		do
			-- return 0 if ship status(sunk or not sunk) doesn't change
--			across before as be loop
--				ships_status_before.force (be.item, ships_status_before.upper)
--			end

			index := 0
			Result := index
			across ships_list as shp loop
				b := True
				index := index + 1
				b2 := ships_status[index]
				if shp.item.dir then
					across shp.item.row |..| (shp.item.row + shp.item.size - 1) as i loop
						if g.board[i.item + 1,shp.item.col].item ~ 'X' then
							b := b and True
						else
							b := False
						end
					end
				else
					across shp.item.col |..| (shp.item.col + shp.item.size - 1) as i loop
						if g.board[shp.item.row,i.item + 1].item ~ 'X' then
							b := b and True
						else
							b := False
						end
					end
				end
				if b then
					ships_status[index] := True
				end
				if not b ~ b2 then
					Result := index
				end
			end
		end

	out : STRING
		local
			ship_status_index : INTEGER
		do
			ship_status_index := 1
			create Result.make_from_string ("  ")
			Result.append ("state " + model_state.out + " " + state_message + " -> " + s)
			if model_state > 0 and not never_started then
				if debug_mode then
					Result.append (g.out)
				else
					Result.append (g.out_game)
				end
				Result.append ("%N  Current Game")
				if debug_mode then
					Result.append (" (debug)")
				end
				Result.append (": " + current_game.out)
				Result.append ("%N  Shots: " + shots.current_value.out + "/" + shots.out_of.out)
				Result.append ("%N  Bombs: " + bombs.current_value.out + "/" + bombs.out_of.out)
				Result.append ("%N  Score: " + score.current_value.out + "/" + score.out_of.out + " (Total: " + total.current_value.out + "/" + total.out_of.out + ")")
				Result.append ("%N  Ships: " + ships.current_value.out + "/" + ships.out_of.out)
				across ships_list as shp loop
					Result.append ("%N    " + shp.item.size.out + "x1: ")
					if debug_mode then
						if shp.item.dir then
							across shp.item.row |..| (shp.item.row + shp.item.size - 1) as i loop
								if shp.item.row < i.item then
									Result.append(";")
								end
								Result.append ("[" + row_indices[i.item + 1].out + ",")
								if shp.item.col < 10 then
									Result.append (" ")
								end
								Result.append (shp.item.col.out + "]->" + g.board[i.item + 1,shp.item.col].out)
							end
						else
							across shp.item.col |..| (shp.item.col + shp.item.size - 1) as i loop
								if shp.item.col < i.item then
									Result.append(";")
								end
								Result.append ("[" + row_indices[shp.item.row].out + ",")
								if i.item < 9 then
									Result.append (" ")
								end
								Result.append ((i.item + 1).out + "]->" + g.board[shp.item.row,i.item + 1].out)
							end
						end
					else
						if not ships_status[ship_status_index] then
							Result.append ("Not ")
						end
						Result.append ("Sunk")
					end
					ship_status_index := ship_status_index + 1
				end
			end
		end


end




