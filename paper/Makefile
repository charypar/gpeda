RM	 = /bin/rm -f
OUT = gecco_lb_abstract.pdf
SRC = gecco_lb_abstract.tex
BIB = gecco_lb_abstract
TMP = gecco_lb_abstract.aux gecco_lb_abstract.log gecco_lb_abstract.bbl gecco_lb_abstract.blg

all: $(OUT)
$(OUT): clean single
	bibtex $(BIB)
	pdflatex $(SRC)
	pdflatex $(SRC)
single: 
	pdflatex $(SRC)
display: $(OUT)
	open $(OUT) # Platform dependent
clean:
	$(RM) $(OUT) $(TMP)
