#Makefile con todo el flujo de trabajo para GOWIN. Utilizando Yosys, nextpnr, iverilog, gtkwave y openFPGALoader

#FPGA a utilizar... Esto no se debe modificar para efectos del curso.
BOARD   = tangnano9k
FAMILY  = GW1N-9C
DEVICE  = GW1NR-LV9QN88PC6/I5

PROYECT = proyecto2

#Fuentes de diseno
SOURCES     := $(wildcard ../design/*.sv)
#Fuente de simulacion
TESTBENCH   = ../sim/tb_top.sv
# Constraints para el proyecto
CONSTRAINTS = ../constr/constraints.cst

#el top se indica sin la extension .v, esto hace referencia al nombre que le pusieron al módulo y no al archivo en si.
TOP_DESIGN = top
TOP_TB     = tb_top

#nombre del vcd que va a generar el tb
VCD_FILE = tb_top.vcd


all: synth pnr bitstream

# Synthesis
synth: ${SOURCES}
	@echo "Ejecutando la sintesis..."
	@yosys -p "read_verilog -sv ${SOURCES}; synth_gowin -top ${TOP_DESIGN} -json ${PROYECT}.json" > synthesis.log 2>&1
	@echo "COMPLETADO"

# Place & Route
pnr: ${PROYECT}.json
	@echo "Ejecutando el pnr..."
	@nextpnr-gowin --json ${PROYECT}.json --write ${PROYECT}_pnr.json --freq 27 --device ${DEVICE} --family ${FAMILY} --cst ${CONSTRAINTS} > pnr.log 2>&1
	@echo "COMPLETADO"

# Generar el Bitstream
bitstream: ${PROYECT}_pnr.json
	@echo "Generando ${PROYECT}_${BOARD}.fs"
	@gowin_pack -d ${FAMILY} -o ${PROYECT}.fs ${PROYECT}_pnr.json
	@echo "COMPLETADO"

# Cargar el bitstream en la FPGA
load: ${PROYECT}.fs
	@echo "Cargando a la FPGA..."
	@openFPGALoader -b ${BOARD} ${PROYECT}.fs

#Generar vcd con icarus verilog
test: ${SOURCES} ${TESTBENCH}
	@echo "Ejecutando Simulacion..."
	@iverilog -o ${PROYECT}_test.o -s ${TOP_TB} -g2005-sv ${TESTBENCH} ${SOURCES}
	@vvp ${PROYECT}_test.o

# --- Ver Ondas ---
wv: ${VCD_FILE}
	gtkwave ${VCD_FILE}

# --- Limpiar (Versión corregida para Windows) ---
clean:
	@echo "Limpiando archivos generados"
	@del /F /Q *.json *.fs *.o *.vcd *.log 2>nul || (exit 0)

.PHONY: all synth pnr bitstream test wv load clean
.INTERMEDIATE: ${PROYECT}_pnr.json ${PROYECT}.json