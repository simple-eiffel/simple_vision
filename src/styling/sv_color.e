note
	description: "Color abstraction for simple_vision theming"
	author: "Larry Rix"
	date: "$Date$"
	revision: "$Revision$"

class
	SV_COLOR

inherit
	ANY
		redefine
			out,
			is_equal
		end

create
	make,
	make_rgb,
	make_rgba,
	make_from_hex,
	make_from_ev_color

feature {NONE} -- Initialization

	make
			-- Create default color (black).
		do
			red := 0
			green := 0
			blue := 0
			alpha := 255
		ensure
			is_black: red = 0 and green = 0 and blue = 0
			is_opaque: alpha = 255
		end

	make_rgb (r, g, b: INTEGER)
			-- Create color from RGB values (0-255).
		require
			valid_red: r >= 0 and r <= 255
			valid_green: g >= 0 and g <= 255
			valid_blue: b >= 0 and b <= 255
		do
			red := r
			green := g
			blue := b
			alpha := 255
		ensure
			red_set: red = r
			green_set: green = g
			blue_set: blue = b
			is_opaque: alpha = 255
		end

	make_rgba (r, g, b, a: INTEGER)
			-- Create color from RGBA values (0-255).
		require
			valid_red: r >= 0 and r <= 255
			valid_green: g >= 0 and g <= 255
			valid_blue: b >= 0 and b <= 255
			valid_alpha: a >= 0 and a <= 255
		do
			red := r
			green := g
			blue := b
			alpha := a
		ensure
			red_set: red = r
			green_set: green = g
			blue_set: blue = b
			alpha_set: alpha = a
		end

	make_from_hex (a_hex: STRING)
			-- Create color from hex string (#RGB, #RRGGBB, or #RRGGBBAA).
		require
			valid_hex: a_hex /= Void and then not a_hex.is_empty
			starts_with_hash: a_hex.item (1) = '#'
		local
			l_hex: STRING
		do
			l_hex := a_hex.substring (2, a_hex.count)
			if l_hex.count = 3 then
				-- #RGB -> #RRGGBB
				red := hex_to_int (l_hex.substring (1, 1) + l_hex.substring (1, 1))
				green := hex_to_int (l_hex.substring (2, 2) + l_hex.substring (2, 2))
				blue := hex_to_int (l_hex.substring (3, 3) + l_hex.substring (3, 3))
				alpha := 255
			elseif l_hex.count = 6 then
				-- #RRGGBB
				red := hex_to_int (l_hex.substring (1, 2))
				green := hex_to_int (l_hex.substring (3, 4))
				blue := hex_to_int (l_hex.substring (5, 6))
				alpha := 255
			elseif l_hex.count = 8 then
				-- #RRGGBBAA
				red := hex_to_int (l_hex.substring (1, 2))
				green := hex_to_int (l_hex.substring (3, 4))
				blue := hex_to_int (l_hex.substring (5, 6))
				alpha := hex_to_int (l_hex.substring (7, 8))
			else
				-- Invalid format, default to black
				red := 0
				green := 0
				blue := 0
				alpha := 255
			end
		end

	make_from_ev_color (a_color: EV_COLOR)
			-- Create from EV_COLOR.
		require
			color_exists: a_color /= Void
		do
			red := a_color.red_8_bit
			green := a_color.green_8_bit
			blue := a_color.blue_8_bit
			alpha := 255
		end

feature -- Access

	red: INTEGER
			-- Red component (0-255).

	green: INTEGER
			-- Green component (0-255).

	blue: INTEGER
			-- Blue component (0-255).

	alpha: INTEGER
			-- Alpha component (0-255, 0=transparent, 255=opaque).

feature -- Conversion

	to_ev_color: EV_COLOR
			-- Convert to EV_COLOR.
		do
			create Result.make_with_8_bit_rgb (red, green, blue)
		end

	to_hex: STRING
			-- Convert to hex string (#RRGGBB or #RRGGBBAA).
		do
			if alpha = 255 then
				Result := "#" + int_to_hex (red) + int_to_hex (green) + int_to_hex (blue)
			else
				Result := "#" + int_to_hex (red) + int_to_hex (green) + int_to_hex (blue) + int_to_hex (alpha)
			end
		end

	out: STRING
			-- String representation.
		do
			Result := to_hex
		end

feature -- Status

	is_opaque: BOOLEAN
			-- Is color fully opaque?
		do
			Result := alpha = 255
		end

	is_transparent: BOOLEAN
			-- Is color fully transparent?
		do
			Result := alpha = 0
		end

feature -- Comparison

	is_equal (other: like Current): BOOLEAN
			-- Is `other` equal to Current?
		do
			Result := red = other.red and green = other.green and
			          blue = other.blue and alpha = other.alpha
		end

feature -- Operations

	with_alpha (a_alpha: INTEGER): SV_COLOR
			-- New color with different alpha.
		require
			valid_alpha: a_alpha >= 0 and a_alpha <= 255
		do
			create Result.make_rgba (red, green, blue, a_alpha)
		ensure
			same_rgb: Result.red = red and Result.green = green and Result.blue = blue
			new_alpha: Result.alpha = a_alpha
		end

	lighten (a_amount: REAL): SV_COLOR
			-- Lighten color by amount (0.0 to 1.0).
		require
			valid_amount: a_amount >= 0.0 and a_amount <= 1.0
		local
			l_r, l_g, l_b: INTEGER
		do
			l_r := (red + ((255 - red).to_real * a_amount)).rounded.min (255)
			l_g := (green + ((255 - green).to_real * a_amount)).rounded.min (255)
			l_b := (blue + ((255 - blue).to_real * a_amount)).rounded.min (255)
			create Result.make_rgba (l_r, l_g, l_b, alpha)
		end

	darken (a_amount: REAL): SV_COLOR
			-- Darken color by amount (0.0 to 1.0).
		require
			valid_amount: a_amount >= 0.0 and a_amount <= 1.0
		local
			l_r, l_g, l_b: INTEGER
		do
			l_r := (red - (red.to_real * a_amount)).rounded.max (0)
			l_g := (green - (green.to_real * a_amount)).rounded.max (0)
			l_b := (blue - (blue.to_real * a_amount)).rounded.max (0)
			create Result.make_rgba (l_r, l_g, l_b, alpha)
		end

feature -- Predefined Colors

	white: SV_COLOR
			-- White color.
		once
			create Result.make_rgb (255, 255, 255)
		end

	black: SV_COLOR
			-- Black color.
		once
			create Result.make_rgb (0, 0, 0)
		end

	transparent: SV_COLOR
			-- Fully transparent color.
		once
			create Result.make_rgba (0, 0, 0, 0)
		end

	red_color: SV_COLOR
			-- Red color.
		once
			create Result.make_rgb (255, 0, 0)
		end

	green_color: SV_COLOR
			-- Green color.
		once
			create Result.make_rgb (0, 255, 0)
		end

	blue_color: SV_COLOR
			-- Blue color.
		once
			create Result.make_rgb (0, 0, 255)
		end

feature {NONE} -- Implementation

	hex_to_int (a_hex: STRING): INTEGER
			-- Convert 2-character hex string to integer.
		local
			l_char: CHARACTER
			l_val: INTEGER
			i: INTEGER
		do
			from
				i := 1
			until
				i > a_hex.count
			loop
				l_char := a_hex.item (i).as_lower
				if l_char >= '0' and l_char <= '9' then
					l_val := l_char.code - ('0').code
				elseif l_char >= 'a' and l_char <= 'f' then
					l_val := l_char.code - ('a').code + 10
				else
					l_val := 0
				end
				Result := Result * 16 + l_val
				i := i + 1
			end
		end

	int_to_hex (a_int: INTEGER): STRING
			-- Convert integer (0-255) to 2-character hex string.
		require
			valid_int: a_int >= 0 and a_int <= 255
		local
			l_high, l_low: INTEGER
		do
			l_high := a_int // 16
			l_low := a_int \\ 16
			create Result.make (2)
			Result.append_character (hex_char (l_high))
			Result.append_character (hex_char (l_low))
		ensure
			two_chars: Result.count = 2
		end

	hex_char (a_val: INTEGER): CHARACTER
			-- Convert value (0-15) to hex character.
		require
			valid_val: a_val >= 0 and a_val <= 15
		do
			if a_val < 10 then
				Result := (('0').code + a_val).to_character_8
			else
				Result := (('A').code + (a_val - 10)).to_character_8
			end
		end

invariant
	valid_red: red >= 0 and red <= 255
	valid_green: green >= 0 and green <= 255
	valid_blue: blue >= 0 and blue <= 255
	valid_alpha: alpha >= 0 and alpha <= 255

end
