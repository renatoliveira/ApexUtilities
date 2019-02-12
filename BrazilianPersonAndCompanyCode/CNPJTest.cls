@IsTest
private class CNPJTest {
    @IsTest
    static void test_cnpj () {
        String validDocument = '05.299.823/0001-83';
        String invalidDocument = '05.299.823/0001-84';
        Boolean valid = CNPJ.isValid(validDocument);
        Boolean invalid = CNPJ.isValid(invalidDocument);
        System.assertEquals(true, valid);
        System.assertEquals(false, invalid);

        validDocument = CNPJ.generate();
        System.debug(validDocument);
        invalidDocument = CNPJ.generate() + '0';
        System.debug(invalidDocument);
        valid = CNPJ.isValid(validDocument);
        invalid = CNPJ.isValid(invalidDocument);
        System.assertEquals(true, valid);
        System.assertEquals(false, invalid);

        invalid = CNPJ.isValid('0');
        System.assertEquals(false, invalid);

        System.assertEquals('05.299.823/0001-83', CNPJ.format('05299823000183'));
    }
}