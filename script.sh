#!/bin/bash
set -e

# 1️⃣ Variables
PROJECT_DIR="$HOME/creatorDriver/esp32c3"
DOCKER_IMAGE="espidf:lastest"
GDB_PORT=3333
UART_PORT="/dev/ttyUSB0"
BAUDRATE=115200
TARGET="esp32c3"

# 2️⃣ Compilar en Docker
docker run --rm -v "$PROJECT_DIR":/project -w /project $DOCKER_IMAGE \
    /bin/bash -c "idf.py set-target $TARGET"

docker run --rm -v "$PROJECT_DIR":/project -w /project $DOCKER_IMAGE \
    /bin/bash -c "idf.py build"
# 2️⃣ Compilar en Docker
docker run --rm --device=$UART_PORT -v "$PROJECT_DIR":/project -w /project $DOCKER_IMAGE \
    /bin/bash -c "idf.py -p $UART_PORT flash"

# 3️⃣ Abrir OpenOCD en host
echo "Iniciando OpenOCD en host..."
source ~/.espressif/python_env/idf5.3_py3.9_env/bin/activate 
. $HOME/esp/v5.3/esp-idf/export.sh
openocd -f ../$PROJECT_DIR/openocd_scripts/openscript_esp32c3.cfg > $HOME/creatorDockerScript/log.txt 2>&1 &

# 4️⃣ Esperar un segundo para que OpenOCD arranque
sleep 1

# 5️⃣ Abrir GDBGUI en Docker y conectarse a OpenOCD del host
docker run --rm -it --network host -v "$PROJECT_DIR":/project -w /project $DOCKER_IMAGE \
    /bin/bash -c "gdbgui -g 'riscv32-esp-elf-gdb -x ./gdbinit' --host 0.0.0.0 --no-browser"
# docker run --rm --network host -v "$PROJECT_DIR":/project -w /project $DOCKER_IMAGE \
#   /bin/bash -c "gdbgui -g 'riscv32-esp-elf-gdb -x ./gdbinit' --host 0.0.0.0 --no-browser > /dev/null 2>&1 &"

  

# 6️⃣ Abrir UART en host
# echo "Conectando UART..."
# screen $UART_PORT $BAUDRATE