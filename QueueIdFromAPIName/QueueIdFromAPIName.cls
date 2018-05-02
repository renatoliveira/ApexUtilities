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
 * Use this class within a Flow to get a queue Id, for example.
 */
public with sharing class QueueIdFROMAPIName {
    @InvocableMethod(Label='Queue ID by its name.' Description='Gets the queue id by providing its API name.')
    public static List<Id> getQueueId (List<String> queueAPIName) {
        List<Group> queues = [SELECT
                Id
                FROM Group
                WHERE Type = 'Queue'
                AND DeveloperName IN :queueAPIName
        ];
        return getIds(queues);
    }

    /**
     * Iterates the group objects received and return the records' Ids.
     *
     * @param groups Groups to iterate
     *
     * @return groups ids
     */
    @TestVisible
    private static List<Id> getIds (List<Group> groups) {
        List<Id> result = new List<Id>();
        for (Group g : groups) {
            result.add(g.Id);
        }
        return result;
    }
}