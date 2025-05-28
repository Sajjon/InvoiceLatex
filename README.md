# LaTeX Invoice
This is an invoice template in (Lua)LaTeX, which requires no input other than **one initial config** of `.envrc.secret` file.

# Requirements
With minimal modification this ought to work on Linux too, but I've only verified it on macOS.

## LaTeX
Install [LaTeX (MacTeX) here](https://tug.org/mactex/)

## `direnv`
Install [direnv](https://direnv.net/)

```bash
brew install direnv
```

# Installation
Clone this repo, then cd to it.

## Create `.envrc.secret`
Make copy of `.envrc.example` and call it `.envrc.secret`

```bash
cp .envrc.example .envrc.secret 
```

Replace the placeholder values from `.envrc.example` with your company, client and project values.

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