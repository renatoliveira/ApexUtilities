@IsTest
private class CPFTest {

    @IsTest
    static void test_cpf () {
        String validDocument = '455.538.410-54';
        String invalidDocument = '455.538.410-55';
        Boolean valid = CPF.isValid(validDocument);
        Boolean invalid = CPF.isValid(invalidDocument);
        System.assertEquals(true, valid);
        System.assertEquals(false, invalid);

        validDocument = CPF.generate();
        invalidDocument = CPF.generate() + '0';
        valid = CPF.isValid(validDocument);
        invalid = CPF.isValid(invalidDocument);
        System.assertEquals(true, valid);
        System.assertEquals(false, invalid);

        System.assertEquals('455.538.410-54', CPF.format('45553841054'));
    }
}
