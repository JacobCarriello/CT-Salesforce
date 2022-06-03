global class CTUtils {

    global static String convertToTitleCase (String stringToConvert) {
        String convertedString = '';
        Set <String> forceLower = new Set <String> {'THE','OF','BY','TO','AND','AT','A','WITH'}; //JC - Set of words that should be lower case
        Set <String> forceUpper = (Set <String>)JSON.deserialize(System.Label.Job_Titles_Force_Upper,Set <String>.class); //JC - Set of words that should be upper case
        Set <String> forceAll = new Set <String> ();
        forceAll.addAll(forceLower);
        forceAll.addAll(forceUpper);
    
        if (stringToConvert != null && stringToConvert.length() > 0) {
            String[] splitStringToConvert = stringToConvert.trim().split(' ');
            for (Integer i = 0; i < splitStringToConvert.size(); i++) {
                try {convertedString += (!forceAll.contains(splitStringToConvert[i].toUpperCase()) || i == 0 || i == (splitStringToConvert.size() - 1)) ? splitStringToConvert[i].toLowerCase().capitalize() + ' ' : (forceLower.contains(splitStringToConvert[i].toUpperCase())) ? splitStringToConvert[i].toLowerCase() + ' ' : splitStringToConvert[i].toUpperCase() + ' ';} catch (Exception e) {System.debug('AccountGateway.convertToTitleCase error : ' + e);convertedString += splitStringToConvert;}
            }
        }
        return String.isBlank(convertedString) ? stringToConvert : convertedString.trim();
    }
}