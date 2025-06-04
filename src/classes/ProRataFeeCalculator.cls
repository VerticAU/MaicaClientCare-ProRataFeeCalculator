public with sharing class ProRataFeeCalculator {
    /**
     * Calculates the pro rata modifier.
     *
     * @param actualStart      The start date of the actual service delivery
     * @param actualEnd        The end date of the actual service delivery
     * @param periodStart      The start date of the target period (e.g., billing or reporting period)
     * @param periodEnd        The end date of the target period
     * @param serviceFrequency One of 'Daily', 'Weekly', 'Monthly'; defines the base unit of the service cycle
     * @param scheduleCount    A multiplier indicating how many frequency units make up a full cycle (e.g., 2 = biweekly, 3 = quarterly)
     * @return Decimal prorated modifier, rounded to 2 decimal places
     */
    public static Decimal calculateProRataModifier(
        Date actualStart,
        Date actualEnd,
        Date periodStart,
        Date periodEnd,
        String serviceFrequency,
        Integer scheduleCount
    ) {
        if (actualStart == null || actualEnd == null || periodStart == null || periodEnd == null || 
            serviceFrequency == null || scheduleCount == null || scheduleCount <= 0) {
            return 0.0;
        }

        Date overlapStart = actualStart > periodStart ? actualStart : periodStart;
        Date overlapEnd = actualEnd < periodEnd ? actualEnd : periodEnd;

        if (overlapStart > overlapEnd) {
            return 0.0;
        }

        Integer overlapDays = overlapStart.daysBetween(overlapEnd) + 1;

        Integer cycleLength;
        serviceFrequency = serviceFrequency.trim().toLowerCase();

        if (serviceFrequency == 'daily') {
            cycleLength = 1 * scheduleCount;
        } else if (serviceFrequency == 'weekly') {
            cycleLength = 7 * scheduleCount;
        } else if (serviceFrequency == 'monthly') {
            Date cycleEnd = periodStart.addMonths(scheduleCount);
            cycleLength = periodStart.daysBetween(cycleEnd);
        } else {
            return 0.0;
        }

        if (cycleLength <= 0) {
            return 0.0;
        }

        Decimal modifier = Decimal.valueOf(overlapDays) / Decimal.valueOf(cycleLength);
        Decimal prorataModifier = modifier.setScale(2, RoundingMode.HALF_UP);

        return prorataModifier;
    }
}