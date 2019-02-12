public class CPF  {

    // private static void validateVerificationDigit (String code) {
    //     Integer firstVerificationDigit = null;
    //     Integer secondVerificationDigit = null;
    //     Integer verificationDigit = null;
    //     String cpfAux = filterDigits(code);
    //     if ((cpfAux.equals('00000000000')) || (cpfAux.equals('11111111111')) ||
    //             (cpfAux.equals('22222222222')) || (cpfAux.equals('33333333333')) ||
    //             (cpfAux.equals('44444444444')) || (cpfAux.equals('55555555555')) ||
    //             (cpfAux.equals('66666666666')) || (cpfAux.equals('77777777777')) ||
    //             (cpfAux.equals('88888888888')) || (cpfAux.equals('99999999999'))) {
    //         throw new InvalidDocumentException('CPF inválido.');
    //     }
    //     firstVerificationDigit = Integer.valueOf(cpfAux.substring(9, 10));
    //     verificationDigit = calculateFirstVerificationDigit(cpfAux);
    //     if (firstVerificationDigit != verificationDigit) {
    //         throw new InvalidDocumentException('O primeiro dígito verificador do CPF está incorreto.');
    //     }
    //     secondVerificationDigit = Integer.valueOf(cpfAux.substring(10));
    //     verificationDigit = calculateSecondVerificationDigit(cpfAux);
    //     if (secondVerificationDigit != verificationDigit) {
    //         throw new InvalidDocumentException('O segundo dígito verificador do CPF está incorreto.');
    //     }
    // }

    // private static Integer calculateFirstVerificationDigit (String code) {
    //     Integer restoDivisao = null;
    //     Integer firstVerificationDigit = null;
    //     List<Integer> arrVerificacao = new List<Integer>{10, 9, 8, 7, 6, 5, 4, 3, 2};
    //     Integer sum = 0;
    //     for (Integer i = 0; i < arrVerificacao.size(); i++) {
    //         sum += arrVerificacao[i] * (Integer.valueOf(code.substring(i, i+1)));
    //     }
    //     restoDivisao = Math.mod(sum, 11);
    //     firstVerificationDigit = (restoDivisao < 2) ? 0 : (11 - restoDivisao);
    //     return firstVerificationDigit;
    // }

    // private static Integer calculateSecondVerificationDigit (String code) {
    //     Integer restoDivisao = null;
    //     Integer secondVerificationDigit = null;
    //     List<Integer> arrVerificacao = new List<Integer>{11, 10, 9, 8, 7, 6, 5, 4, 3, 2};
    //     Integer sum = 0;
    //     for (Integer i = 0; i < arrVerificacao.size(); i++) {
    //         sum += arrVerificacao[i] * (Integer.valueOf(code.substring(i, i+1)));
    //     }
    //     restoDivisao = Math.mod(sum, 11);
    //     secondVerificationDigit = (restoDivisao < 2) ? 0 : (11 - restoDivisao);
    //     return secondVerificationDigit;
    // }

    private static String filterDigits (String code) {
        return code.replace('\\D', '');
    }

    public static String getVerificationDigit (String num) {
        Integer firstDigit, secondDigit;
        Integer sum = 0, weight = 10;
        for (Integer i = 0; i < num.length(); i++) {
            sum += Integer.valueOf(num.substring(i, i + 1)) * weight--;
        }
        if (Math.mod(sum, 11) == 0 | Math.mod(sum, 11) == 1) {
            firstDigit = 0;
        } else {
            firstDigit = 11 - (Math.mod(sum, 11));
        }
        sum = 0;
        weight = 11;
        for (Integer i = 0; i < num.length(); i++) {
            sum += Integer.valueOf(num.substring(i, i + 1)) * weight--;
        }
        sum += firstDigit * 2;
        if (Math.mod(sum, 11) == 0 | Math.mod(sum, 11) == 1) {
            secondDigit = 0;
        } else {
            secondDigit = 11 - (Math.mod(sum, 11));
        }
        return String.valueOf(firstDigit) + String.valueOf(secondDigit);
    }

    public static String generate () {
        String digits = '';
        Integer numberx;
        for (Integer i = 0; i < 9; i++) {
            numberx = Integer.valueOf((Math.random() * 10));
            digits += String.valueOf(numberx);
        }
        return digits + getVerificationDigit(digits);
    }

    public static Boolean isValid (String cpf) {
        cpf = cpf.replaceAll('\\D', '');
        if (cpf.length() != 11) {
            return false;
        }
        String numDig = cpf.substring(0, 9);
        return getVerificationDigit(numDig).equals(cpf.substring(9, 11));
    }

    public static String format (String code) {
        return code.substring(0, 3) + '.' + code.substring(3, 6) + '.' +
            code.substring(6, 9) + '-' + code.substring(9);
    }

    public class InvalidDocumentException extends Exception {}
}