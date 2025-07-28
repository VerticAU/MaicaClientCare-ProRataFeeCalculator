@isTest
private class ProRataFeeCalculatorTest {

    @isTest
    static void testActualAndRawDatesTheSame() {
        // serviceFrequency: 'Weekly', scheduleCount: 2, actual and raw periods start and end on the same dates
        Date actualStart = Date.newInstance(2025, 5, 15);
        Date actualEnd = Date.newInstance(2025, 5, 27);
        Date periodStart = Date.newInstance(2025, 5, 15);
        Date periodEnd = Date.newInstance(2025, 5, 27); 

        Decimal result = ProRataFeeCalculator.calculateProRataModifier(
            actualStart, actualEnd, periodStart, periodEnd, 'Week', 2
        );

        System.assertEquals(1, result);
    }
    
    @isTest
    static void testBiweeklyService() {
        // serviceFrequency: 'Weekly', scheduleCount: 2, overlap: 10 days, cycleLength: 14 days
        Date actualStart = Date.newInstance(2025, 6, 1);
        Date actualEnd = Date.newInstance(2025, 6, 10);
        Date periodStart = Date.newInstance(2025, 6, 1);
        Date periodEnd = Date.newInstance(2025, 6, 14); 

        Decimal result = ProRataFeeCalculator.calculateProRataModifier(
            actualStart, actualEnd, periodStart, periodEnd, 'Week', 2
        );

        Decimal expected = Decimal.valueOf(10).divide(14, 2, RoundingMode.HALF_UP); // 0.71
        System.assertEquals(expected, result, 'Biweekly service prorate modifier mismatch');
    }

    @isTest
    static void testQuarterlyService() {
        // serviceFrequency: 'Monthly', scheduleCount: 3, periodStart: Jan 1, periodEnd: Apr 1 (3 months = 90 days approx), overlap: 60 days (Jan 1 - Mar 1)
        Date actualStart = Date.newInstance(2025, 1, 1);
        Date actualEnd = Date.newInstance(2025, 3, 1);
        Date periodStart = Date.newInstance(2025, 1, 1);
        Date periodEnd = Date.newInstance(2025, 4, 1); 

        Decimal result = ProRataFeeCalculator.calculateProRataModifier(
            actualStart, actualEnd, periodStart, periodEnd, 'Month', 3
        );

        Integer cycleLength = periodStart.daysBetween(periodStart.addMonths(3)); 
        Integer overlapDays = actualStart.daysBetween(actualEnd) + 1; 

        Decimal expected = Decimal.valueOf(overlapDays).divide(cycleLength, 2, RoundingMode.HALF_UP); // 0.67
        System.assertEquals(expected, result, 'Quarterly service prorate modifier mismatch');
    }
    
    @isTest
    static void testDailyFrequency_FullOverlap() {
        Date startDate = Date.newInstance(2025, 6, 1);
        Date endDate = Date.newInstance(2025, 6, 10);
        Decimal result = ProRataFeeCalculator.calculateProRataModifier(
            startDate, endDate, startDate, endDate, 'Day', 10
        );
        System.assertEquals(1.00, result);
    }

    @isTest
    static void testWeeklyFrequency_PartialOverlap() {
        Date actualStart = Date.newInstance(2025, 6, 5);
        Date actualEnd = Date.newInstance(2025, 6, 14);
        Date periodStart = Date.newInstance(2025, 6, 1);
        Date periodEnd = Date.newInstance(2025, 6, 10);

        Decimal result = ProRataFeeCalculator.calculateProRataModifier(
            actualStart, actualEnd, periodStart, periodEnd, 'Week', 2
        );

        // 6 overlapping days (June 5 to 10), cycle length = 10 days
        Decimal expected = Decimal.valueOf(6).divide(10, 2, RoundingMode.HALF_UP); // = 0.60

        System.assertEquals(expected, result);
    }

    @isTest
    static void testMonthlyFrequency_FullCycle() {
        Date startDate = Date.newInstance(2025, 6, 1);
        Date endDate = Date.newInstance(2025, 6, 30);
        Decimal result = ProRataFeeCalculator.calculateProRataModifier(
            startDate, endDate, startDate, endDate, 'Month', 1
        );
        System.assertEquals(0.99, result);
    }

    @isTest
    static void testMonthlyFrequency_PartialCycle() {
        Date actualStart = Date.newInstance(2025, 6, 15);
        Date actualEnd = Date.newInstance(2025, 6, 30);
        Date periodStart = Date.newInstance(2025, 6, 1);
        Date periodEnd = Date.newInstance(2025, 6, 30);
        Decimal result = ProRataFeeCalculator.calculateProRataModifier(
            actualStart, actualEnd, periodStart, periodEnd, 'Month', 1
        );
        Decimal expected = Decimal.valueOf(16).divide(30, 2, RoundingMode.HALF_UP);
        System.assertEquals(expected, result);
    }

    @isTest
    static void testInvalidFrequency() {
        Decimal result = ProRataFeeCalculator.calculateProRataModifier(
            Date.today(), Date.today().addDays(10), Date.today(), Date.today().addDays(10), 'Year', 1
        );
        System.assertEquals(0.00, result);
    }

    @isTest
    static void testZeroScheduleCount() {
        Decimal result = ProRataFeeCalculator.calculateProRataModifier(
            Date.today(), Date.today().addDays(5), Date.today(), Date.today().addDays(5), 'Day', 0
        );
        System.assertEquals(0.00, result);
    }

    @isTest
    static void testNoOverlap() {
        Date actualStart = Date.newInstance(2025, 5, 1);
        Date actualEnd = Date.newInstance(2025, 5, 10);
        Date periodStart = Date.newInstance(2025, 6, 1);
        Date periodEnd = Date.newInstance(2025, 6, 10);
        Decimal result = ProRataFeeCalculator.calculateProRataModifier(
            actualStart, actualEnd, periodStart, periodEnd, 'Day', 10
        );
        System.assertEquals(0.00, result);
    }

    @isTest
    static void testNullInputs() {
        Decimal result = ProRataFeeCalculator.calculateProRataModifier(
            null, null, null, null, null, null
        );
        System.assertEquals(0.00, result);
    }
}