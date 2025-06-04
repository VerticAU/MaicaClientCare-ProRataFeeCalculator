https://verticconsulting.atlassian.net/browse/MEC-152

## Solution Overview

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
