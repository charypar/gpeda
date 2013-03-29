RM	 = /bin/rm -f
OUT = gecco_lb_abstract.pdf
SRC = gecco_lb_abstract.tex
BIB = gecco_lb_abstract
TMP = gecco_lb_abstract.aux gecco_lb_abstract.log gecco_lb_abstract.bbl gecco_lb_abstract.blg

all: display
$(OUT): clean
	pdflatex $(SRC)
	bibtex $(BIB)
	pdflatex $(SRC)
	pdflatex $(SRC)
display: $(OUT)
	open $(OUT) # Platform dependent
clean:
	$(RM) $(OUT) $(TMP)
