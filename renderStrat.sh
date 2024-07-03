#!/bin/bash

echo "start renderStrat.sh script ..."

TICK=${3:-0.01}
SCALE_FACTOR=${4:-1}
ASSET=$2
STRAT=$1
echo "STRAT: ${STRAT}"
echo "ASSET: ${ASSET}"
echo "TICK:  ${TICK}"
echo "SCALE_FACTOR:  ${SCALE_FACTOR}"

# Ejecutar el script fetch_data.sh para recopilar los datos
. /home/jaime/Documentos/Cardano-Latino/axo-strat-visualiser/fetch_data.sh
fetch_data $STRAT $ASSET "/home/jaime/Documentos/Cardano-Latino/axo-strat-visualiser/renderStrat_database/"

echo ""
echo "::::"
echo "curl requests ended. fetch_data() exited. back into renderStrat.sh"

# Ejecutar el script renderStrat1TimeStorageFactory.js para preparar los datos para el renderizado
node /home/jaime/Documentos/Cardano-Latino/axo-strat-visualiser/renderStrat1TimeStorageFactory.js $STRAT $ASSET $TICK $SCALE_FACTOR


# # Enviar correo con los resultados
# SUBJECT="Axo Strategy"
# BODY="Strategy ID: $STRAT, Asset: $ASSET, Profit Percentage: $PROFIT_PERCENT%"
# echo -e "Subject:${SUBJECT}\n\n${BODY}" | ssmtp support@cardanolatino.com

flatpak run com.google.Chrome /home/jaime/Documentos/Cardano-Latino/axo-strat-visualiser/renderStrat_page/index.html
echo ""
echo "link to html page:"
echo "/home/jaime/Documentos/Cardano-Latino/axo-strat-visualiser/renderStrat_page/index.html"

# Opcional: Eliminar archivos de datos fetch para limpiar
# echo "deleting fetch_data jsons ..."
# rm /home/jaime/Documentos/Cardano-Latino/axo-strat-visualiser/renderStrat_database/*.json
# echo "deleted."