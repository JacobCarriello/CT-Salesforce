@isTest
public class TestCTUtils {

    @isTest
    static void testConvertToTitleCase () {
        String stringToConvert = 'TEST THE STRING TO CONVERT';
        System.debug(':::::: TestCTUtils + testConvertToTitleCase + String to Convert : ' + stringToConvert);

        String convert = CTUtils.convertToTitleCase(stringToConvert);
        System.debug(':::::: TestCTUtils + testConvertToTitleCase + Converted String : ' + convert);
    }
}