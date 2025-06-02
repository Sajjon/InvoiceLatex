INPUT_FILE=invoice
INPUT_PATH=src
OUTPUT=build
INVOICES_FOLDER=invoices
INVOICE_NUMBER_AND_DATE_FILE=temp_invoice_name_and_date.txt
INVOICE_NUMBER_AND_DATE_SEP="_"

.PHONY: bau clean ooo __luatex_build_with_ooo_days ___luatex_build_with_ooo_days

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

__luatex_build_with_ooo_days:
	@$(MAKE) ___luatex_build_with_ooo_days INVOICE_NUMBER_AND_DATE_PATH=$(dir $(abspath $(lastword $(MAKEFILE_LIST))))$(OUTPUT)/$(INVOICE_NUMBER_AND_DATE_FILE) INVOICE_NUMBER_AND_DATE_SEPARATOR=$(INVOICE_NUMBER_AND_DATE_SEP)

# Internal target to run LaTeX with environment variable
#
# Implementation:
# @mkdir -p $(OUTPUT): create output folder if needed.
# @TEXINPUTS=./$(INPUT_PATH): tells luatex to search for files in `$INPUT_PATH`.
# lualatex --halt-on-error --interaction=nonstopmode: ensures to not wait for input when luatex encounters an error.
# grep: Finds the Lua error line in logic.lua including 2 lines after (like a wrapped message)
# sed: Cleans the prefix (./logic.lua:111:) so only the error message remains.
# fold: Wraps long lines nicely in your terminal (optional but makes things prettier).
___luatex_build_with_ooo_days:
	@mkdir -p $(OUTPUT)
	@mkdir -p $(INVOICES_FOLDER)
	@echo "🔧 Building invoice (OOO_DAYS=$(OOO_DAYS))..."
	@TEXINPUTS=./$(INPUT_PATH): lualatex --halt-on-error --interaction=nonstopmode --output-directory=$(OUTPUT) $(INPUT_PATH)/$(INPUT_FILE).tex > $(OUTPUT)/build.log 2>&1 || (\
	  echo "❌ LuaLaTeX build failed. Extracting error:"; \
	  grep -A 2 '^.*logic.lua:[0-9]*:' build/build.log | sed 's/^.*logic.lua:[0-9]*: //' | fold -s; \
	  exit 1 \
	)
	@echo "✅ LuaLaTeX build successful (OOO_DAYS=$(OOO_DAYS))" && \
	INVOICE_NUMBER_AND_DATE_CONCATENATED=$$(cat $(INVOICE_NUMBER_AND_DATE_PATH) | tr ' ' $(INVOICE_NUMBER_AND_DATE_SEPARATOR)); \
	INVOICE_NUMBER=$$(echo $$INVOICE_NUMBER_AND_DATE_CONCATENATED | cut -d $(INVOICE_NUMBER_AND_DATE_SEPARATOR) -f 1); \
	INVOICE_DATE=$$(echo $$INVOICE_NUMBER_AND_DATE_CONCATENATED | cut -d $(INVOICE_NUMBER_AND_DATE_SEPARATOR) -f 2); \
	echo "🧾 Invoice number: '$$INVOICE_NUMBER'" && \
	echo "📅 Invoice date: '$$INVOICE_DATE'" && \
	INVOICE_FILE_NAME=$${INVOICE_DATE}_invoice_$${INVOICE_NUMBER}.pdf && \
	echo "📁 INVOICE_FILE_NAME='$$INVOICE_FILE_NAME'" && \
	INVOICE_FILE_PATH=$(INVOICES_FOLDER)/$$INVOICE_FILE_NAME && \
	echo "🌈 INVOICE_FILE_PATH='$$INVOICE_FILE_PATH'" && \
	mv $(OUTPUT)/$(INPUT_FILE).pdf $$INVOICE_FILE_PATH && \
	open $$INVOICE_FILE_PATH