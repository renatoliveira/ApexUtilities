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
 * Attachment and ContentDocument are different. Attachment holds the information about the file directly attached
 * to the parent object. ContentDocument, however, specifies a file, but does not hold its content. In Lightning
 * Experience the content can have different versions. So the file's actual data is stored in a related object
 * called 'ContentVersion'. This object has a parameter to determine if it is the latest version or not.
 *
 * Attachment:                     Account -> Attachment
 *
 * ContentVersion/ContentDocument: Account -> ContentDocument -> ContentVersion
 */
global class FlowEmailSender {
    /**
     * Main send method to send emails. The 'SendCommand' is an inner class with the basic attributes for sending the
     * email message. This is necessary because invocable methods cannot have more than one parameter. So we create
     * an inner class with invocable variables that can be set by the flow interface.
     *
     * @param params send commands
     *
     * @return send results. NOTE: The results only contain the record Id if the send is unsuccessful.
     */
    @InvocableMethod
    global static List<SendCommandResult> send (List<SendCommand> params) {
        System.debug(LoggingLevel.FINE, params);
        List<SendCommandResult> commandResults = new List<SendCommandResult>();
        List<Messaging.SendEmailResult> sendResults = new List<Messaging.SendEmailResult>();
        List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
        Map<String, Id> templates = getTemplates(params);
        Map<Id, CommandAttachment> files = getAttachments(params);
        for (SendCommand command : params) {
            Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
            msg.setWhatId(command.recordId);
            if (command.targetId != null) {
                msg.setTargetObjectId(command.targetId);
            }
            if (command.relatedAttachments != null) {
                msg.setFileAttachments(getEmailFileAttachments(command.relatedAttachments, files));
            }
            if (templates.containsKey(command.emailTemplateAPIName)) {
                msg.setTemplateId(templates.get(command.emailTemplateAPIName));
            }
            if (command.ccAddresses != null) {
                msg.setCcAddresses(command.ccAddresses);
            }
            if (command.bccAddresses != null) {
                msg.setBccAddresses(command.bccAddresses);
            }
            if (msg.getTemplateId() != null) {
                messages.add(msg);
            }
            if (command.targetId.left(3) == Schema.User.SObjectType.getDescribe().getKeyPrefix()) {
                msg.setSaveAsActivity(false);
            } else {
                msg.setSaveAsActivity(command.saveAsActivity != null ? command.saveAsActivity : true);
            }
        }
        sendResults = Messaging.sendEmail(messages, true);
        for (Messaging.SendEmailResult sr : sendResults) {
            SendCommandResult re = new SendCommandResult();
            re.success = sr.isSuccess();
            List<Messaging.SendEmailError> errors = sr.getErrors();
            for (Messaging.SendEmailError err : errors) {
                if (re.recordId == null) {
                    re.recordId = err.getTargetObjectId();
                }
                if (re.errorMessage == null) {
                    String errString = String.format('{0} > {1} > {2}', new List<String>{
                            err.getStatusCode()+'',
                            err.getFields()+'',
                            err.getMessage()
                    });
                    System.debug(LoggingLevel.ERROR, errString);
                    re.errorMessage = errString;
                }
            }
            commandResults.add(re);
        }
        return commandResults;
    }

    /**
     * Given a list of attachments ids and a collection of attachments, retrieve those we are specifying.
     *
     * @param attachmentsIds Ids of the specific attachments we want.
     * @param attachments Collection of attachments
     *
     * @return List of attachments
     */
    private static List<Messaging.EmailFileAttachment> getEmailFileAttachments (List<String> attachmentsIds, Map<Id, CommandAttachment> attachments) {
        List<Messaging.EmailFileAttachment> result = new List<Messaging.EmailFileAttachment>();
        for (String attachmentId : attachmentsIds) {
            if (attachments.containsKey(Id.valueOf(attachmentId))) {
                CommandAttachment ca = attachments.get(Id.valueOf(attachmentId));
                Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                efa.setBody(ca.getBody());
                efa.setFileName(ca.getName());
                result.add(efa);
            }
        }
        return result;
    }

    /**
     * Retrieves the email templates with their ids.
     *
     * @param params commands
     *
     * @return map of email template API Name to email template Id
     */
    private static Map<String, Id> getTemplates (List<SendCommand> params) {
        Map<String, Id> result = new Map<String, Id>();
        Set<String> apiNames = new Set<String>();
        for (SendCommand c : params) {
            apiNames.add(c.emailTemplateAPIName);
        }
        List<EmailTemplate> templates = [SELECT Id, DeveloperName FROM EmailTemplate WHERE DeveloperName IN :apiNames];
        for (EmailTemplate template : templates) {
            result.put(template.DeveloperName, template.Id);
        }
        return result;
    }

    /**
     * Returns an object representing the attachment (a single representation for Attachment and ContentDocument
     * records).
     *
     * @param commands Commands to send email.
     */
    private static Map<Id, CommandAttachment> getAttachments (List<SendCommand> commands) {
        Map<Id, CommandAttachment> result = new Map<Id, CommandAttachment>();
        Set<Id> attachmentsIds = new Set<Id>();
        Set<Id> contentDocumentsIds = new Set<Id>();
        for (SendCommand command : commands) {
            if (command.relatedAttachments != null) {
                Map<SObjectType, Set<Id>> files = sortAttachmentsByType(command.relatedAttachments);
                attachmentsIds.addAll(files.get(Attachment.SObjectType));
                contentDocumentsIds.addAll(files.get(ContentDocument.SObjectType));
            }
        }
        List<Attachment> attachments = [
                SELECT
                Id
                ,Name
                ,Body
                FROM Attachment
                WHERE Id IN :attachmentsIds
        ];
        List<ContentVersion> contents = [
                SELECT
                Id
                ,ContentDocument.FileExtension
                ,ContentDocument.Title
                FROM ContentVersion
                WHERE ContentDocumentId IN :contentDocumentsIds
        ];
        for (Attachment a : attachments) {
            result.put(a.Id, new CommandAttachment(a));
        }
        for (ContentVersion c : contents) {
            result.put(c.ContentDocumentId, new CommandAttachment(c));
        }
        return result;
    }

    /**
     * Sorts the attachments ids into 'attachments' and 'content documents' maps, to query separately.
     *
     * @param attachmentsIds List of ids. Can contain Attachment and ContentDocument objects ids.
     *
     * @return Map with those ids sorted by object.
     */
    private static Map<SObjectType, Set<Id>> sortAttachmentsByType (List<String> attachmentsIds) {
        Map<SObjectType, Set<Id>> result = new Map<SObjectType, Set<Id>>();
        result.put(Attachment.SObjectType, new Set<Id>());
        result.put(ContentDocument.SObjectType, new Set<Id>());
        for (String attachmentId : attachmentsIds) {
            if (attachmentId.left(3) == Attachment.SObjectType.getDescribe().getKeyPrefix()) {
                result.get(Attachment.SObjectType).add(attachmentId);
            } else if (attachmentId.left(3) == ContentDocument.SObjectType.getDescribe().getKeyPrefix()) {
                result.get(ContentDocument.SObjectType).add(attachmentId);
            }
        }
        return result;
    }

    /**
     * Represents an attachment within the platform. Attachments are used on Salesforce Classic, and ContentDocuments
     * are used on Lightning Experience (see the first comment in this class).
     */
    global class CommandAttachment {
        public SObject record;
        private SObjectType kind;

        public CommandAttachment (SObject record) {
            this.record = record;
            this.kind = String.valueOf(record.Id).left(3) == Attachment.getSObjectType().getDescribe().getKeyPrefix()
                    ? Attachment.SObjectType
                    : ContentDocument.SObjectType;
        }
        public String getName () {
            if (kind == Attachment.SObjectType) {
                return ((Attachment) record).Name;
            }
            return ((ContentVersion) record).Title + ((ContentVersion) record).FileExtension;
        }

        public Blob getBody () {
            if (kind == Attachment.SObjectType) {
                return ((Attachment) record).Body;
            }
            return ((ContentVersion) record).VersionData;
        }
    }

    /**
     * A 'send email' command that is fired from the flow. At least the email template and record Id are required.
     * The other parameters are all optional.
     */
    global class SendCommand {
        @InvocableVariable(Label='Email template name (API Name)' Required=true)
        public String emailTemplateAPIName;
        @InvocableVariable(Label='Record Id' Required=true)
        public String recordId;
        @InvocableVariable(Label='Target Object Id')
        public String targetId;
        @InvocableVariable(Label='CC Addresses')
        public List<String> ccAddresses;
        @InvocableVariable(Label='BCC Addresses')
        public List<String> bccAddresses;
        @InvocableVariable(Label='Attachments (optional)')
        public List<String> relatedAttachments;
        @InvocableVariable(Label='Save as activity')
        public Boolean saveAsActivity;
    }

    /**
     * Represents the result of the operation. 'recordId' and 'errorMessage' can only be filled when an error occurs.
     * That is: when 'success' is false.
     */
    global class SendCommandResult {
        @InvocableVariable
        public Boolean success;
        @InvocableVariable
        public String recordId;
        @InvocableVariable
        public String errorMessage;
    }
}

