public with sharing class ProRataFeeCalculator {

    public class InputWrapper {
        @InvocableVariable(required=true)
        public Date actualStart;

        @InvocableVariable(required=true)
        public Date actualEnd;

        @InvocableVariable(required=true)
        public Date periodStart;

        @InvocableVariable(required=true)
        public Date periodEnd;

        @InvocableVariable(required=true)
        public String serviceFrequency;

        @InvocableVariable(required=true)
        public Integer scheduleCount;
    }

    public class OutputWrapper {
        @InvocableVariable
        public Decimal prorataModifier;
    }

    @InvocableMethod(label='Calculate Pro Rata Modifier')
    public static List<OutputWrapper> calculateProRataModifierFromFlow(List<InputWrapper> requests) {
        List<OutputWrapper> results = new List<OutputWrapper>();

        for (InputWrapper req : requests) {
            OutputWrapper res = new OutputWrapper();
            res.prorataModifier = calculateProRataModifier(
                req.actualStart,
                req.actualEnd,
                req.periodStart,
                req.periodEnd,
                req.serviceFrequency,
                req.scheduleCount
            );
            results.add(res);
        }

        return results;
    }

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

        if (serviceFrequency == 'day') {
            cycleLength = 1 * scheduleCount;
        } else if (serviceFrequency == 'week') {
            cycleLength = periodStart.daysBetween(periodEnd) + 1;
        } else if (serviceFrequency == 'month') {
            Date cycleEnd = periodStart.addMonths(scheduleCount);
            cycleLength = periodStart.daysBetween(cycleEnd);
        } else {
            return 0.0;
        }

        if (cycleLength <= 0) {
            return 0.0;
        }

        Decimal modifier = ( serviceFrequency == 'month' &&  overlapDays != cycleLength ) ?
            Decimal.valueOf(overlapDays) * Decimal.valueOf((12 / scheduleCount)) / 365 :
            Decimal.valueOf(overlapDays) / Decimal.valueOf(cycleLength);
        Decimal prorataModifier = modifier.setScale(2, RoundingMode.HALF_UP);

        return prorataModifier;
    }
}