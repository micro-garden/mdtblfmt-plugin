VERSION = "0.0.1"

local micro = import("micro")
local config = import("micro/config")
local buffer = import("micro/buffer")

function format_table_block(lines)
	local rows = {}
	local alignments = {}

	for i, line in ipairs(lines) do
		local display_cells = {}
		local raw_cells = {}

		for cell in line:gmatch("|?%s*(.-)%s*|") do
			table.insert(raw_cells, cell)

			if i == 2 then
				table.insert(display_cells, "")
			else
				table.insert(display_cells, cell)
			end
		end

		table.insert(rows, display_cells)

		if i == 2 then
			for _, cell in ipairs(raw_cells) do
				if cell:match("^:%-+:$") then
					table.insert(alignments, "center")
				elseif cell:match("^:%-+$") then
					table.insert(alignments, "left")
				elseif cell:match("^%-+:$") then
					table.insert(alignments, "right")
				elseif cell:match("^%-+$") then
					table.insert(alignments, "none") -- implicit left
				else
					table.insert(alignments, "left") -- fallback
				end
			end
		end
	end

	local max_cols = 0
	for _, row in ipairs(rows) do
		if #row > max_cols then
			max_cols = #row
		end
	end

	local col_widths = {}
	for col = 1, max_cols do
		local max_len = 0
		for _, row in ipairs(rows) do
			local cell = row[col] or ""
			if #cell > max_len then
				max_len = #cell
			end
		end
		col_widths[col] = max_len
	end

	local formatted_lines = {}

	for i, row in ipairs(rows) do
		local parts = {}
		for col = 1, max_cols do
			local cell = row[col] or ""
			local width = col_widths[col]
			local align = alignments[col] or "left"

			if i == 2 then
				if align == "left" then
					if width < 2 then
						width = 2
					end
					cell = ":" .. string.rep("-", width - 1)
				elseif align == "right" then
					if width < 2 then
						width = 2
					end
					cell = string.rep("-", width - 1) .. ":"
				elseif align == "center" then
					if width < 3 then
						width = 3
					end
					cell = ":" .. string.rep("-", width - 2) .. ":"
				elseif align == "none" then
					local n = math.max(width, 3)
					cell = string.rep("-", n)
				else
					cell = string.rep("-", width)
				end
			else
				if align == "right" then
					cell = string.rep(" ", width - #cell) .. cell
				elseif align == "center" then
					local pad = width - #cell
					local left = math.floor(pad / 2)
					local right = pad - left
					cell = string.rep(" ", left) .. cell .. string.rep(" ", right)
				else -- left or none
					cell = cell .. string.rep(" ", width - #cell)
				end
			end

			table.insert(parts, " " .. cell .. " ")
		end

		table.insert(formatted_lines, "|" .. table.concat(parts, "|") .. "|")
	end

	return formatted_lines
end

-- search and format table blocks in the buffer
function MdTblFmt(bp)
	local buf = bp.Buf
	local lines = {}
	for i = 0, buf:LinesNum() - 1 do
		lines[i] = buf:Line(i)
	end

	local i = 0
	while i < #lines do
		-- find table block start
		if lines[i]:match("^|") then
			local block_start = i
			while i + 1 < #lines and lines[i + 1]:match("^|") do
				i = i + 1
			end
			local block_end = i

			-- format table block
			local block_lines = {}
			for j = block_start, block_end do
				table.insert(block_lines, lines[j])
			end

			local new_lines = format_table_block(block_lines)
			if new_lines then
				local start = buffer.Loc(0, block_start)
				local ending = buffer.Loc(#lines[block_end], block_end)
				buf:Remove(start, ending)

				buf:Insert(start, table.concat(new_lines, "\n"))
			end
		end
		i = i + 1
	end

	micro.InfoBar():Message("Tables formatted.")
end

function init()
	config.MakeCommand("mdtblfmt", MdTblFmt, config.NoComplete)
	config.AddRuntimeFile("mdtblfmt", config.RTHelp, "help/mdtblfmt.md")
end
