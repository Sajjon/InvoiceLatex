INPUT_FILE=invoice
INPUT_PATH=src
OUTPUT=build
INVOICES_FOLDER=invoices
INVOICE_NUMBER_AND_DATE_FILE=temp_invoice_name_and_date.txt
export INVOICE_NUMBER_AND_DATE_SEPARATOR="_"
export INVOICE_NUMBER_AND_DATE_PATH=$(dir $(abspath $(lastword $(MAKEFILE_LIST))))$(OUTPUT)/$(INVOICE_NUMBER_AND_DATE_FILE)

.PHONY: build clean do_build

# Default target to run LaTeX with environment variable
# 
# Usage:
# make
# make DAYS_OFF=5
#
# Implementation:
# @mkdir -p $(OUTPUT): create output folder if needed.
# @TEXINPUTS=./$(INPUT_PATH): tells luatex to search for files in `$INPUT_PATH`.
# lualatex --halt-on-error --interaction=nonstopmode: ensures to not wait for input when luatex encounters an error.
# grep: Finds the Lua error line in logic.lua including 2 lines after (like a wrapped message)
# sed: Cleans the prefix (./logic.lua:111:) so only the error message remains.
# fold: Wraps long lines nicely in your terminal (optional but makes things prettier).
build:
	@$(MAKE) do_build \
	 || (\
	  echo "❌ LuaLaTeX build failed. Extracting error:"; \
	  grep -A 2 '^.*logic.lua:[0-9]*:' build/build.log | sed 's/^.*logic.lua:[0-9]*: //' | fold -s; \
	  exit 1 \
	)
	@echo "✅ LuaLaTeX build successful." && \
	INVOICE_NUMBER_AND_DATE_CONCATENATED=$$(cat $(INVOICE_NUMBER_AND_DATE_PATH) | tr ' ' $(INVOICE_NUMBER_AND_DATE_SEPARATOR)); \
	INVOICE_NUMBER=$$(echo $$INVOICE_NUMBER_AND_DATE_CONCATENATED | cut -d $(INVOICE_NUMBER_AND_DATE_SEPARATOR) -f 1); \
	INVOICE_DATE=$$(echo $$INVOICE_NUMBER_AND_DATE_CONCATENATED | cut -d $(INVOICE_NUMBER_AND_DATE_SEPARATOR) -f 2); \
	INVOICE_FILE_NAME=$${INVOICE_DATE}_invoice_$${INVOICE_NUMBER}.pdf && \
	INVOICE_FILE_PATH=$(INVOICES_FOLDER)/$$INVOICE_FILE_NAME && \
	echo "📁 created invoice at '$$INVOICE_FILE_PATH', opening it now..." && \
	mv $(OUTPUT)/$(INPUT_FILE).pdf $$INVOICE_FILE_PATH && \
	open $$INVOICE_FILE_PATH

do_build: 
	@./assert_required_packages_installed.sh
	@mkdir -p $(OUTPUT)
	@mkdir -p $(INVOICES_FOLDER)
	@echo "🔧 Building invoice (days off=$(DAYS_OFF))..."
	@TEXINPUTS=./$(INPUT_PATH): lualatex --shell-escape --halt-on-error --interaction=nonstopmode --output-directory=$(OUTPUT) $(INPUT_PATH)/$(INPUT_FILE).tex

clean:
	@rm -rf build/
	@echo "🧹 Cleaned"