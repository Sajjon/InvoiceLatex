INPUT_FILE=invoice
INPUT_PATH=src
OUTPUT=build

.PHONY: bau clean ooo __luatex_build_with_ooo_days

# Business As Usual (BAU) - all working days worked.
# Default target
bau:
	@$(MAKE) __luatex_build_with_ooo_days OOO_DAYS=0

clean:
	@rm -rf build/
	@echo "🧹 Cleaned"

# Out of Office (OOO) for `DAYS` many days
ooo:
ifndef DAYS
	$(error You must specify DAYS, e.g., 'make ooo DAYS=4')
endif
	@$(MAKE) __luatex_build_with_ooo_days OOO_DAYS=$(DAYS)

# Internal target to run LaTeX with environment variable
#
# Implementation:
# @mkdir -p $(OUTPUT): create output folder if needed.
# @TEXINPUTS=./$(INPUT_PATH): tells luatex to search for files in `$INPUT_PATH`.
# lualatex --halt-on-error --interaction=nonstopmode: ensures to not wait for input when luatex encounters an error.
# grep: Finds the Lua error line in logic.lua including 2 lines after (like a wrapped message)
# sed: Cleans the prefix (./logic.lua:111:) so only the error message remains.
# fold: Wraps long lines nicely in your terminal (optional but makes things prettier).
__luatex_build_with_ooo_days:
	@mkdir -p $(OUTPUT)
	@echo "🔧 Building invoice (OOO_DAYS=$(OOO_DAYS))..."
	@TEXINPUTS=./$(INPUT_PATH): lualatex --halt-on-error --interaction=nonstopmode --output-directory=$(OUTPUT) $(INPUT_PATH)/$(INPUT_FILE).tex > $(OUTPUT)/build.log 2>&1 || (\
	  echo "❌ LuaLaTeX build failed. Extracting error:"; \
	  grep -A 2 '^.*logic.lua:[0-9]*:' build/build.log | sed 's/^.*logic.lua:[0-9]*: //' | fold -s; \
	  exit 1 \
	)
	@echo "✅ LuaLaTeX build successful (OOO_DAYS=$(OOO_DAYS))"
	@open $(OUTPUT)/$(INPUT_FILE).pdf