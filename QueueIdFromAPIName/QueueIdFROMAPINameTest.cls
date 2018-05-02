/*
 * Copyright 2018 Renato Oliveira
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of
 * this software and associated documentation files (the "Software"), to deal in
 * the Software without restriction, including without limitation the rights to
 * use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
 * the Software, and to permit persons to whom the Software is furnished to do so,
 * subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 *
 */

/**
 * Queues are not available by default on the platform. They are metadata created by the user,
 * so we can't actually test the retrieval from the query. We can, however, test the method
 * that receives the records and returns their Ids and assert that the method returns no
 * queue when called.
 */

@IsTest
private class QueueIdFROMAPINameTest {
    @IsTest
    public static void test_query () {
        List<Id> result = QueueIdFROMAPIName.getQueueId(new List<String>{'QUEUE_API_NAME'});
        System.assert(result.size() == 0, 'Shouldn\'t have received a queue here. Do you really ' +
                'have a queue in your system with the API name "QUEUE_API_NAME"?');
    }

    @IsTest
    public static void test_getIds () {
        Id queueId = IDGenerator.generate(Group.SObjectType);
        Group dummyQueue = new Group(Id=queueId);
        List<Id> result = QueueIdFROMAPIName.getIds(new List<Group>{dummyQueue});
        System.assert(result.size() == 1, 'Should have returned the single queue Id.');
        System.assert(result[0] == queueId);
    }
}