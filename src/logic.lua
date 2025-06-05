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
function get_last_day_prev_month_as_date()
  local today = os.date("*t")
  local prev_month = today.month - 1
  local year = today.year

  if prev_month == 0 then
    prev_month = 12
    year = year - 1
  end

  local last_day_ts = os.time{year = today.year, month = today.month, day = 0}
  local last_day_date = os.date("*t", last_day_ts)
  return new_date(year, prev_month, last_day_date.day)
end

function get_last_day_prev_month()
    local date = get_last_day_prev_month_as_date()
    return format_date(date)
end

-- Return YYYY-MM
function get_last_month_str()
    local date = get_last_day_prev_month_as_date()
    return format_date_as_year_and_month(date)
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

-- === Simulated Enum: Currency ===
Currency = {
  EUR = "EUR",
  ALL = "ALL",
  AMD = "AMD",
  AZN = "AZN",
  BAM = "BAM",
  BGN = "BGN",
  CHF = "CHF",
  CZK = "CZK",
  DKK = "DKK",
  GEL = "GEL",
  GBP = "GBP",
  HUF = "HUF",
  ISK = "ISK",
  MDL = "MDL",
  MKD = "MKD",
  NOK = "NOK",
  PLN = "PLN",
  RON = "RON",
  RSD = "RSD",
  RUB = "RUB",
  SEK = "SEK",
  TRY = "TRY",
  UAH = "UAH",
}

-- === Structs ===
function new_date(y, m, d)
  return { year = tonumber(y), month = tonumber(m), day = tonumber(d) }
end
function new_date_from_string(s)
  local y, m, d = s:match("(%d+)%-(%d+)%-(%d+)")
  return new_date(y, m, d)
end

-- Returns YYYY-MM
function format_date_as_year_and_month(date)
    local year = date.year
    if not year then
        error("Date argument not proper Daet struct, missing 'year' field.")
    end
    local month = date.month
    if not month then
        error("Date argument not proper Date struct, missing 'month' field.")
    end
  return string.format("%04d-%02d", year, month)
end

function format_date(date)
    local year = date.year
    if not year then
        error("Date argument not proper Daet struct, missing 'year' field.")
    end
    local month = date.month
    if not month then
        error("Date argument not proper Date struct, missing 'month' field.")
    end
    local day = date.day
    if not day then
        error("Date argument not proper Date struct, missing 'day' field.")
    end
  return string.format("%04d-%02d-%02d", year, month, day)
end

function new_expense(item, currency, cost, quantity, date)
  return {
    item = item,
    currency = currency,
    cost = cost,
    quantity = quantity,
    date = date
  }
end

function format_product_row(expense)
  return string.format("\\product{%s}{%.2f}{%.2f}", expense.item, expense.cost, expense.quantity)
end


-- date should be `YYYY-MM-DD`
function fetch_exchange_rate_str(date, from, to)
  if from == to then return 1.0 end
  local url = string.format("https://api.frankfurter.app/%s?from=%s&to=%s", date, from, to)
  local cmd = string.format("curl -s \"%s\"", url)
  local handle = io.popen(cmd)
  local result = handle:read("*a")
  handle:close()

  -- Build pattern for extracting the rate
  local pattern = '"' .. to .. '"%s*:%s*([%d%.]+)'
  local rate = result:match(pattern)

  if rate then
    return tonumber(rate)
  else
    return nil
  end
end

-- Pure Lua function: returns the exchange rate as a float
function fetch_exchange_rate(date, from, to)
    local date_str = format_date(date) -- Ensure date is formatted correctly
    return fetch_exchange_rate_str(date_str, from, to)
end


-- Invoice month should be in the format "YYYY-MM"
function expenses_for_month_as_string(invoice_month, target_currency)
  local raw = os.getenv("INVOICE_EXPENSES_PER_MONTH")
  if not raw then return "" end

  local chunk, err = load("return " .. raw)
  if not chunk then
    tex.print("Error loading data: " .. (err or ""))
    return ""
  end

  local all_expenses = chunk()
  local expenses_for_month = all_expenses[invoice_month]
  if not expenses_for_month then return "" end

  -- local output = "\"" .. expenses_for_month.description .. "\""
  local output = ""
  local exchange_rates = {}
  local number_of_entries = #expenses_for_month.entries
  if number_of_entries > 0 then
    output = "\\hdashline"
  end
  for index, entry in ipairs(expenses_for_month.entries) do
    -- Format: "2025-05-01,Coffee,4.5,GBP,1"
    local date_str, item, cost, currency, quantity = entry:match("([^,]+),([^,]+),([^,]+),([^,]+),(%d+%.?%d*)")
    cost = tonumber(cost)
    if not cost then
      error("Invalid cost value: " .. entry)
      return ""
    end
    if date_str == nil or date_str == "" then
      error("Invalid date value: " .. entry)
      return ""
    end
    if currency == nil or currency == "" then
      error("Invalid currency value: " .. entry)
      return ""
    end
    if quantity == nil or quantity == "" then
       error("Invalid quantity value: " .. entry)
      return ""
    end
    quantity = tonumber(quantity)
    if quantity == nil or quantity == 0 then quantity = 1 end

    local date = new_date_from_string(date_str)
    local key = currency .. "_" .. target_currency
    local rate = exchange_rates[key]

    if not rate then
      rate = fetch_exchange_rate(date, currency, target_currency)
      exchange_rates[key] = rate
    end

    local converted_cost = cost * rate
    local expense = new_expense(item, target_currency, converted_cost, quantity, date)
    local row = format_product_row(expense)

    output = output .. row
    local is_last = (index == number_of_entries)
    if not is_last then
      output = output .. "\\hdashline"
    end
  end

  return output
end

function is_expense()
  -- TODO: fix logic
  return true
end

function cost_legend_pure()
  if is_expense() then
    return "Price in local currency translated to " .. _get_env("CURRENCY") .. " using exchange rate at date of purchase."
  end
  return "Daily Rate"
end

function cost_legend()
  tex.print(cost_legend_pure())
end

function emit_expenses_products()
  local product_table = expenses_for_month_as_string(get_last_month_str(), _get_env("CURRENCY"))

    -- local file_path = "product_table.txt"  -- Change path if needed
    -- local file = io.open(file_path, "w")
    -- if not file then
    --     error("Could not open file for writing: " .. file_path)
    -- end
    -- file:write(product_table)
    -- file:close()
    -- error("🌈 Product table written to " .. file_path)

  -- tex.sprint(tex.ctxcatcodes, product_table)
  -- return product_table
  tex.print(product_table)
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