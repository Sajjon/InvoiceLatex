INPUT_FILE=invoice
INPUT_PATH=src
OUTPUT=build

.PHONY: bau clean ooo ooo_inner

# Business As Usual (BAU) - all working days worked.
# Default target
bau:
	@$(MAKE) ooo_inner OOO_DAYS=0

clean:
	@rm -rf build/
	@echo "🧹 Cleaned"

# Out of Office (OOO) for `DAYS` many days
ooo:
ifndef DAYS
	$(error You must specify DAYS, e.g., 'make ooo DAYS=4')
endif
	@$(MAKE) ooo_inner OOO_DAYS=$(DAYS)

# Internal target to run LaTeX with environment variable
ooo_inner:
	@mkdir -p $(OUTPUT)
	@echo "🔧 Building invoice (OOO_DAYS=$(OOO_DAYS))..."
	@TEXINPUTS=./$(INPUT_PATH): lualatex --halt-on-error --interaction=nonstopmode --output-directory=$(OUTPUT) $(INPUT_PATH)/$(INPUT_FILE).tex > build/build.log 2>&1 || (\
	  echo "❌ LuaLaTeX build failed. See build/build.log for details."; \
	  tail -n 20 build/build.log; \
	  exit 1 \
	)
	@echo "✅ LuaLaTeX build successful (OOO_DAYS=$(OOO_DAYS))"
	@open $(OUTPUT)/$(INPUT_FILE).pdf