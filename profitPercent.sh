#!/bin/bash

# Paths to JSON files
trades_file="/home/jaime/Documentos/Cardano-Latino/axo-strat-visualiser/renderStrat_database/stratTrades.json"
funds_file="/home/jaime/Documentos/Cardano-Latino/axo-strat-visualiser/renderStrat_database/stratUserFunds.json"
orderbook_file="/home/jaime/Documentos/Cardano-Latino/axo-strat-visualiser/renderStrat_database/orderBook.json"

# Extract initial allocations
initialADA=$(jq '.result.totalLiquidity[] | select(.asset_name == "").allocation' $funds_file)
initialAXO=$(jq '.result.totalLiquidity[] | select(.asset_name != "").allocation' $funds_file)

# Get the current spot price of AXO in ADA terms
spotPrice=$(jq '.result.spotSpreadData.spot' $orderbook_file)

# Calculate initial total value in ADA terms
initialTotal=$(echo "$initialADA + ($initialAXO * $spotPrice)" | bc)

# Initialize totals
totalBoughtADA=0
totalSoldADA=0

# Process each trade to update ADA and AXO totals
jq -c '.result[]' $trades_file | while read line; do
    echo "Processing a transaction: $line"
    orderSide=$(echo $line | jq -r '.orderSide')
    amountADA=$(echo $line | jq -r '.sold.amount')
    amountAXO=$(echo $line | jq -r '.received.amount')
    price=$(echo $line | jq -r '.price.value')

    echo "Order Side: $orderSide, Amount ADA: $amountADA, Amount AXO: $amountAXO, Price: $price"

    if [[ "$orderSide" == "SELL" ]]; then
        totalSoldADA=$(echo "$totalSoldADA + ($amountADA * $price)" | bc)
    elif [[ "$orderSide" == "BUY" ]]; then
        totalBoughtADA=$(echo "$totalBoughtADA + ($amountAXO * $price)" | bc)
    fi
done

# Calculate the final total of ADA
finalADA=$(echo "$initialADA + $totalSoldADA - $totalBoughtADA" | bc)

# Calculate final total value in ADA terms
currentTotal=$(echo "$finalADA + ($initialAXO * $spotPrice)" | bc)

# Calculate profit/loss and percentage
profitLoss=$(echo "$currentTotal - $initialTotal" | bc)
profitPercent=$(echo "scale=2; 100 * $profitLoss / $initialTotal" | bc)

# Output results
echo "Initial ADA: $initialADA, Initial AXO: $initialAXO"
echo "Spot Price of AXO in ADA: $spotPrice"
echo "Total Bought (ADA spent on purchases): $totalBoughtADA"
echo "Total Sold (ADA earned from sales): $totalSoldADA"
echo "Final Total ADA (after all transactions): $finalADA"
echo "Initial Total: $initialTotal, Current Total: $currentTotal"
echo "Profit Loss: $profitLoss, Profit Percentage: ${profitPercent}%"

# Saving the profit percentage to a file
echo "Profit Percentage: ${profitPercent}%" > "/home/jaime/Documentos/Cardano-Latino/axo-strat-visualiser/profitPercent.txt"