# Makefile for final.qmd
# DATA 6690: Computational Methods in FinTech

.PHONY: help render html pdf clean

# Default target
help:
	@echo "Available targets:"
	@echo "  make help    - Show this help message"
	@echo "  make render  - Render both HTML and PDF outputs"
	@echo "  make html    - Render HTML output only"
	@echo "  make pdf     - Render PDF output only"
	@echo "  make clean   - Remove all generated files"

# Render both HTML and PDF
render: html pdf

# Render HTML output
html: final.qmd biblio.bib
	quarto render final.qmd --to html

# Render PDF output
pdf: final.qmd biblio.bib
	quarto render final.qmd --to pdf

# Clean generated files
clean:
	rm -f final.html
	rm -f final.pdf
	rm -rf final_files/
	rm -f .quarto/
