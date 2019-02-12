public class CNPJ {

    private static void validateVerificationDigit (String documentNumber) {
        Integer firstVerificationDigit = null;
        Integer secondVerificationDigit = null;
        Integer verificationDigit = null;
        documentNumber = documentNumber.replaceAll('\\D', '');
        if (documentNumber.length() != 14){
            throw new InvalidDocumentException('O CNPJ é inválido.');
        }
        firstVerificationDigit = calculateFirstVerificationDigit(documentNumber);
        secondVerificationDigit = calculateSecondVerificationDigit(documentNumber);
        if ((firstVerificationDigit != Integer.valueOf(documentNumber.substring(12,13))) ||
                (secondVerificationDigit != Integer.valueOf(documentNumber.substring(13)))) {
            throw new InvalidDocumentException('O CNPJ é inválido.');
        }
    }

    public static Integer calculateFirstVerificationDigit (String documentNumber) {
        Integer divisionRemainder = null;
        Integer firstVerificationDigit = null;
        List<Integer> verificationArray = new List<Integer>{5,4,3,2,9,8,7,6,5,4,3,2};
        Integer sum = 0;
        for (Integer i = 0; i < verificationArray.size(); i++) {
            sum += verificationArray[i] * (Integer.valueOf(documentNumber.substring(i,i+1)));
        }
        divisionRemainder = Math.mod(sum,11);
        firstVerificationDigit = (divisionRemainder < 2) ? 0 : (11-divisionRemainder);
        return firstVerificationDigit;
    }

    public static Integer calculateSecondVerificationDigit (String documentNumber) {
        Integer divisionRemainder = null;
        Integer secondVerificationDigit = null;
        List<Integer> verificationArray = new List<Integer>{6,5,4,3,2,9,8,7,6,5,4,3,2};
        Integer sum = 0;
        for (Integer i = 0; i < verificationArray.size(); i++) {
            sum += verificationArray[i] * (Integer.valueOf(documentNumber.substring(i,i+1)));
        }
        divisionRemainder = Math.mod(sum,11);
        secondVerificationDigit = (divisionRemainder < 2) ? 0 : (11-divisionRemainder);
        return secondVerificationDigit;
    }

    public static Boolean isValid (String documentNumber) {
        try {
            validateVerificationDigit(documentNumber);
            return true;
        } catch (InvalidDocumentException ex) {
            // ....
        }
        return false;
    }

    public static String format (String documentNumber) {
        return documentNumber.substring(0, 2) + '.' + documentNumber.substring(2, 5) + '.' +
            documentNumber.substring(5, 8) + '/' + documentNumber.substring(8, 12) + '-' + documentNumber.substring(12);
    }

    public static String generate () {
        String numberx = '';
        Integer n;
        for (Integer i = 0; i < 8; i++) {
            n = Integer.valueOf((Math.random() * 10));
            numberx += String.valueOf(n);
        }
        numberx += '0001';
        Integer firstVDNumber = calculateFirstVerificationDigit(numberx);
        Integer secondVDNumber = calculateSecondVerificationDigit(numberx + firstVDNumber);
        return numberx + firstVDNumber + secondVDNumber;
    }

    public class InvalidDocumentException extends Exception {}
}