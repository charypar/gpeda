RM	 = /bin/rm -f
OUT = gpedaBBOBarticle.pdf
SRC = gpedaBBOBarticle.tex
# BIB = gpedaBBOB.bib
TMP = gpedaBBOBarticle.aux gpedaBBOBarticle.log

all: display
process:
	./process_data.sh
$(OUT): clean
	pdflatex $(SRC)
	bibtex $(BIB)
	pdflatex $(SRC)
	pdflatex $(SRC)
display: $(OUT)
	open $(OUT) # Platform dependent
clean:
	$(RM) $(OUT) $(TMP)
