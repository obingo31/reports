# Quantified Precision Loss Vulnerability

## Impact Analysis

The impact of the precision loss can be significant when considering large-scale operations and long-term effects. Let's analyze different scenarios to quantify the potential loss:

### Scenario 1: Single Transaction Impact

Assume the following values:
- `BASE_SCHNIBBLE_RATE` = 1 schnibble per second
- Time elapsed (`timestamp - _toiler.lastToilDate`) = 1 day (86400 seconds)
- `finalBonus` = 5 (5% bonus)

Normal calculation:
```
schnibblesTotal = 86400 * 1 = 86400
bonusAmount = (86400 * 5) / 100 = 4320
totalSchnibbles = 86400 + 4320 = 90720
```

Actual calculation with integer division:
```
schnibblesTotal = 86400
bonusAmount = (86400 * 5) / 100 = 4320
totalSchnibbles = 90720
```

In this case, there's no loss due to precision in a single transaction.

### Scenario 2: Exploiting Rounding

An attacker could exploit rounding by choosing specific time intervals:

Assume `finalBonus` = 1 (1% bonus)

For a 100-second interval:
```
schnibblesTotal = 100 * 1 = 100
bonusAmount = (100 * 1) / 100 = 1
totalSchnibbles = 101
```

For two 50-second intervals:
```
First interval:
schnibblesTotal = 50 * 1 = 50
bonusAmount = (50 * 1) / 100 = 0
totalSchnibbles = 50

Second interval:
schnibblesTotal = 50 * 1 = 50
bonusAmount = (50 * 1) / 100 = 0
totalSchnibbles = 50

Total for both intervals: 100
```

The attacker gains 1 extra schnibble by timing their actions to avoid rounding down.

### Scenario 3: Long-term Cumulative Effect

Assume an attacker exploits this consistently over a year:

- 365 days * 24 hours * 60 minutes = 525,600 minutes
- If the attacker calls `_farmPlots` every minute perfectly timed:
  - Normal user: 525,600 * 60 * 1.01 = 31,861,440 schnibbles
  - Attacker: 525,600 * 61 = 32,061,600 schnibbles

The attacker gains an extra 200,160 schnibbles over the year, which is about 0.63% more than a normal user.

### Scenario 4: Large-scale Operation

Consider a large-scale farmer with 1000 munchables, each with different bonuses ranging from 1% to 10%.

In a single day:
- Worst case (all 1% bonus): 86,400,000 schnibbles
- Best case (all 10% bonus): 95,040,000 schnibbles
- Actual case (mixed bonuses with rounding errors): ~90,720,000 schnibbles

The difference between the worst and best case is 8,640,000 schnibbles per day. If schnibbles have any real-world value (e.g., $0.01 per 1000 schnibbles), this could translate to $86.40 per day or $31,536 per year in potential manipulated gains.

## Competitive Advantage

The precision loss leads to a competitive advantage in several ways:

1. **Resource Accumulation**: Over time, exploiters can accumulate more schnibbles than fair players, giving them an edge in the game economy.

2. **Optimal Timing**: Knowledgeable players can time their actions to always benefit from favorable rounding, consistently outperforming others.

3. **Scaling Advantage**: The larger a player's operation, the more they can benefit from these small rounding errors, creating a "rich get richer" effect.

4. **Market Manipulation**: If schnibbles can be traded or have in-game value, exploiters could potentially manipulate markets by accumulating large amounts through this exploit.

## Conclusion

While the impact per transaction is small, the cumulative effect over time and across many users can be substantial. In a game economy, even small advantages can compound significantly, potentially disrupting game balance and fairness. If schnibbles have any real-world value or can be exchanged for valuable in-game items, this vulnerability could lead to significant financial implications for both the game operators and fair players.
