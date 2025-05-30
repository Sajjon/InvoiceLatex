# LaTeX Invoice
A config **once**, inter-month-idempotent, calendar aware, and **maintenance-free** invoice solution written in LaTeX + Lua.

# Features
* Config once: Set your company, client and project information using ENV vars in the `.envrc.secret` file (git ignored). **No LaTeX or Lua skills needed!**
* Inter-month-idempotent: You build the invoice any number of times, it always results in the same invoice number when run within the same month. The proceeding month the next invoice number will be used.
* Calendar aware: Using your machines system time to determine the month, it calculates the number of working days for the target month. Invoice date is set to last day of the target month and due date is set dependent on the payment terms set in your ENV config.
* Maintenance free: The invoice number automatically set based on the current month. When you build the invoice the next month, the next number is used.

# Requirements
With minimal modification this ought to work on Linux too, but I've only verified it on macOS.

## LaTeX
Install [LaTeX (MacTeX) here](https://tug.org/mactex/)

## `direnv`
Install [direnv](https://direnv.net/)

```bash
brew install direnv
```

# Setup
Clone this repo, then cd to it.

## Create `.envrc.secret`
Make copy of [`.envrc.example`](.envrc.example) and call it `.envrc.secret`

```bash
cp .envrc.example .envrc.secret 
```

Replace the placeholder values from [`.envrc.example`](.envrc.example) with your company, client and project values.

## Source and make
Source the updated environment variables by calling:
```bash
direnv allow .
```

And now call make:
```bash
make
```

Which will call out to `lualatex`.

# Usage
> [!NOTE]
> All environment variables references to in document are all set in `.envrc.secret` (which you should have copied over from `.envrc.example`).
> They will all be exported when you call `direnv allow .` (needed once and then after each change to `.envrc.secret`, which you typically only upon initial setup)

Build the invoice (`make` standing in the root of this project) on the first day month after the completed month. So if you have finished working in May, wait until June and build it. The invoice date will be set to `2025-05-31` and the due date will be set to `invoice day + $INVOICE_DAYS_DUE_AFTER_END_OF_MONTH`.

Set `INVOICE_NUMBER_BASE_OFFSET = 42` if you have sent 42 invoices already and want the next to invoice to be 43, in order for this to work you need also set `INVOICE_NUMBER_BASE_OFFSET_DATE_MONTH` and `INVOICE_NUMBER_BASE_OFFSET_DATE_YEAR` to the previous month (and relevant year).

## Did not invoice at all for some month?
If you were out of office (OOO) for an entire month, maybe due to parental leave or long vacation or long term sickness, you can set increment `INVOICE_NUMBER_MONTHS_FREE` by how many numbers of months you where OOO. This allows you to not have to "hacky" decrement your `INVOICE_NUMBER_BASE_OFFSET` to get the correct invoice number for the next month.

## Out of office for **some** days?
If you were out of office for some days for the period you are invoicing you can call:

```bash
make ooo DAYS=5
```
Which will subtract 5 from the number of working days that month (as calculated by the Lua script for you).


# Example
If you build the invoice without changing any of the example values from [`.envrc.example`](.envrc.example) it will look like this:

![Example](.github/assets/example_invoice.jpg)

# How it works
`direnv` will source [`.envrc`](.envrc) which in turn will source [`.envrc.example`](.envrc.example) and then if `.envrc.secret` exists, it will source that, effectively overriding the values of `.envrc.example`. If you haven't created `.envrc.secret` yet the values of `.envrc.example` are used instead, or if you were to comment out or remove any variable from  `.envrc.secret`, that variable won't be overridden.

The LaTeX main file [`invoice.tex`](src/invoice.tex) will include other helper files, such as [`logic.tex`](src/logic.tex) which in turn wraps the lua functions inside [`logic.lua`](src/logic.lua) as LaTeX commands.

# Contribute
We use `pre-commit` to run some soundness checks when you try to commit, such as checking for typos.

## Precommit
Install [`pre-commit` CLI tool](https://pre-commit.com/):
```bash
brew install pre-commit
```

## Install pre-commit hooks
```bash
pre-commit install
```