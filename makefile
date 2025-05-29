INPUT_FILE=invoice
INPUT_PATH=src
OUTPUT=build

all:
	@{ \
	  output=$$(mkdir -p $(OUTPUT) && TEXINPUTS=./$(INPUT_PATH): lualatex --output-directory=$(OUTPUT) $(INPUT_PATH)/$(INPUT_FILE).tex 2>&1); \
	  status=$$?; \
	  if [ $$status -eq 0 ]; then \
	    echo "✅ LuaLaTeX build successful"; \
	    open $(OUTPUT)/$(INPUT_FILE).pdf; \
	  else \
	    echo "❌ LuaLaTeX build failed"; \
	    echo "$$output"; \
	    exit $$status; \
	  fi \
	}