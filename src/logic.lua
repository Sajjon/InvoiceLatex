function count_working_days_prev_month()
  local os_date = os.date("*t")
  local year = os_date.year
  local prev_month = os_date.month - 1 

  -- Find number of days in prev month
  local function days_in_month(year, month)
    local next_month = month % 12 + 1
    local next_year = year + math.floor(month / 12)
    local last_day = os.time{year=next_year, month=next_month, day=1} - 86400
    return os.date("*t", last_day).day
  end

  local total_days = days_in_month(year, prev_month)
  local count = 0

  for day = 1, total_days do
    local t = os.time{year=year, month=prev_month, day=day}
    local wday = os.date("*t", t).wday -- 1=Sunday, 2=Monday, ..., 7=Saturday
    if wday >= 2 and wday <= 6 then
      count = count + 1
    end
  end

  tex.print(count)
end

-- Get last day of the previous month as a date string
function get_last_day_prev_month()
  local today = os.date("*t")
  local prev_month = today.month - 1
  local year = today.year

  if prev_month == 0 then
    prev_month = 12
    year = year - 1
  end

  local last_day = os.time{year = today.year, month = today.month, day = 0}
  return os.date("%Y-%m-%d", last_day)
end

-- Return date string of (last day of previous month + offset in days)
function get_last_day_prev_month_plus_offset(offset)
  local last_day = os.time{year = os.date("*t").year, month = os.date("*t").month, day = 0}
  local target_time = last_day + offset * 86400 -- seconds in a day
  return os.date("%Y-%m-%d", target_time)
end

-- invoice_number = invoice_offset + (months_since_reference_month) - subtract_for_vacation
function invoice_number_for_previous_month_offset_by(offset, vacation_months, start_month, start_year)
  local today = os.date("*t")
  local current_month = today.month
  local current_year = today.year

  -- Get year and month for the *previous* month
  current_month = current_month - 1
  if current_month == 0 then
    current_month = 12
    current_year = current_year - 1
  end

  -- Calculate months between (start_year, start_month) and (current_year, current_month)
  local months_elapsed = (current_year - start_year) * 12 + (current_month - start_month)

  local invoice_number = offset + months_elapsed - vacation_months
  return invoice_number
end

-- Returns previous month with year
function get_previous_month_string()
  local now = os.date("*t")
  local year = now.year
  local month = now.month - 1

  if month == 0 then
    month = 12
    year = year - 1
  end

  -- Use Lua's date formatting to get the full month name
  local t = os.time{year = year, month = month, day = 1}
  local result = os.date("%B %Y", t)
  tex.print(result)
end

function _get_env(varname)
  local value = os.getenv(varname)
  if not value then
    error("Environment variable " .. varname .. " is not set!")
  end
  return value
end

function get_env(varname)
    local value = _get_env(varname)
    tex.print(value)
end

-- Function to read an environment variable and return it as an integer,
-- or fall back to a default if not set or not a valid integer
function get_env_with_default(env_name, default_val)
  local val = os.getenv(env_name)
  local num = tonumber(val)
  if num == nil then
    tex.print(default_val)
  else
    tex.print(num)
  end
end

-- Function to calculate days to invoice
function days_to_invoice(working_days, days_off)
  local days_worked = working_days - days_off
  if days_worked < 0 then
    error("You specified too many days out of office, you specified DAYS_OFF=" .. days_off .. ", but the month only has: " .. working_days .. " days.")
  elseif days_worked == 0 then
    error("You were out of office exactly ALL days this month, you should skip invoicing this month and increment the `INVOICE_NUMBER_MONTHS_FREE` variable in `.envrc.secret` by 1.")
  end
  tex.print(days_worked)
end

function _get_invoice_number()
    local invoice_offset = _get_env("INVOICE_NUMBER_BASE_OFFSET")
    local invoice_months_free = _get_env("INVOICE_NUMBER_MONTHS_FREE")
    local invoice_start_month = _get_env("INVOICE_NUMBER_BASE_OFFSET_DATE_MONTH")
    local invoice_start_year = _get_env("INVOICE_NUMBER_BASE_OFFSET_DATE_YEAR")
    return invoice_number_for_previous_month_offset_by(
      math.tointeger(invoice_offset),
      math.tointeger(invoice_months_free),
      math.tointeger(invoice_start_month),
      math.tointeger(invoice_start_year)
    )
end

function get_invoice_number()
  local invoice_number = _get_invoice_number()
  tex.print(invoice_number)
end

function emit_expenses_products()
  local expenses = os.getenv("EXPENSES")
  if not expenses or expenses == "" then return end
  -- Split on ';'
  for entry in string.gmatch(expenses, "([^;]+)") do
    -- Remove leading/trailing quotes and whitespace
    entry = entry:gsub("^['\"]", ""):gsub("['\"]$", ""):gsub("^%s+", ""):gsub("%s+$", "")
    -- Split on ','
    local desc, price, qty = entry:match("([^,]+),([^,]+),([^,]+)")
    if desc and price and qty then
      tex.print("\\hdashline \\product{" .. desc .. "}{" .. price .. "}{" .. qty .. "}")
    end
  end
end

function output_invoice_number_and_date()
    local tmp_file_path_unsanitized = _get_env("INVOICE_NUMBER_AND_DATE_PATH")
    local tmp_file_path = tmp_file_path_unsanitized:gsub("%s+$", "")

    local lfs = require("lfs")
    local dir = string.match(tmp_file_path, "(.*/)")
    if lfs.attributes(dir, "mode") ~= "directory" then
      error("Directory does not exist: " .. dir)
    end

    local file = io.open(tmp_file_path, "w")
    if not file then
      error("Could not open file for writing: " .. tmp_file_path)
    end
    local separator = _get_env("INVOICE_NUMBER_AND_DATE_SEPARATOR")
    local invoice_number = _get_invoice_number()
    local invoice_number_and_invoice_date = invoice_number .. separator .. get_last_day_prev_month()
    file:write(invoice_number_and_invoice_date)
    file:close()
end