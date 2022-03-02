public with sharing class jobsfeedcontroller {

    public String jobsfeed {
        get;
        set;
    }
    public XmlStreamWriter w {
        get;
        set;
    }
    public string JobBoardName;
    map < String, string > jobbrdMap = new Map < string, string > ();
    public jobsfeedcontroller() {
        JobBoardName = ApexPages.currentPage().getParameters().get('jobboard');
        String querystr = 'select Id ';
        for (TR1__LabelUtility__c jbbrd: TR1__LabelUtility__c.getAll().values()) {
            jobbrdMap.put(jbbrd.TR1__Value__c, jbbrd.Name);
        }

        for (TR1__Jobs_Feeds__c jbfeedmap: TR1__Jobs_Feeds__c.getAll().values()) {

            if (jbfeedmap.TR1__field_name__c != null) {
                if (jbfeedmap.TR1__field_name__c != '' && jbfeedmap.TR1__field_name__c != 'Id')
                    querystr += ', ' + jbfeedmap.TR1__field_name__c;
            }
        }
        if(JobBoardName != null)
            querystr += ' from TR1__job__c where TR1__Post_Externally__c=true and TR1__Status__c != \'Closed\' and TR1__Job_Board__c includes (\''+JobBoardName+'\') ';//\'%'+JobBoardName+'%\' 
        //else
        //  querystr += ' from TR1__job__c where TR1__Post_Externally__c=true and TR1__Status__c != \'Closed\' ';
        system.debug('Query: '+querystr);
        List < Sobject > jobsList;
        if(JobBoardName !=  null)
            jobsList = AccessController.queryWithoutSharing(querystr);
        else
            jobsList = new List < Sobject >();
        w = new XmlStreamWriter();

        w.writeStartDocument('utf-8', '1.0');
        w.writeStartElement('', 'source', '');

        w.writeStartElement(null, 'publisher', null);
        w.writeCharacters(Label.JobsFeeds_Publisher);
        w.writeEndElement();

        w.writeStartElement(null, 'publisherurl', null);
        w.writeCharacters(Label.JobsFeeds_PublisherURL);
        w.writeEndElement();

        w.writeStartElement(null, 'lastBuildDate', null);
        w.writeCharacters(System.Now().format());
        w.writeEndElement();

        for (Sobject s: jobsList) {

            w.writeStartElement(null, 'job', null);

            for (Integer i = 1; i <= TR1__Jobs_Feeds__c.getAll().size(); i++) {

                TR1__Jobs_Feeds__c jbfeedmap = TR1__Jobs_Feeds__c.getAll().get(String.valueOf(i));
                w.writeStartElement(null, jbfeedmap.TR1__Element_Name__c, null);
                if (jbfeedmap.TR1__field_name__c != null) {
                    if (jbfeedmap.TR1__field_name__c != '') {
                        String fieldval = String.valueOf(s.get(jbfeedmap.TR1__field_name__c));

                        if (fieldval == null)
                            fieldval = '';

                        if (jbfeedmap.TR1__element_Name__c == 'url') {

                            String jbName = String.valueOf(s.get('TR1__Job_Board__c'));
                            if (JbName == null) {
                                fieldval = Label.JobsFeeds_JobBaseURL + fieldval;
                            } else if (jbName == '') {
                                fieldval = Label.JobsFeeds_JobBaseURL + fieldval;
                            } else if (jbName.contains(';')) {
                                if (jobbrdMap.containskey(jbName.substring(0, jbName.indexOf(';'))))
                                    fieldval = Label.JobsFeeds_JobDomainURL + jobbrdMap.get(jbName.substring(0, jbName.indexOf(';'))) +
                                        '/Jobsearch?JobId=' + fieldval;
                                else
                                    fieldval = Label.JobsFeeds_JobBaseURL + fieldval;
                            } else {
                                if (jobbrdMap.containskey(jbName))
                                    fieldval = Label.JobsFeeds_JobDomainURL + jobbrdMap.get(jbName) +
                                        '/Jobsearch?JobId=' + fieldval;
                                else
                                    fieldval = Label.JobsFeeds_JobBaseURL + fieldval;

                            }

                        }

                        if ((fieldval == null || fieldval == '') && jbfeedmap.TR1__Field_Default_Value__c != null) {
                            fieldval = jbfeedmap.TR1__Field_Default_Value__c;
                        }

                        w.writeCData(fieldval);
                    } else {
                        w.writeCData('');
                    }
                } else {
                    if (jbfeedmap.TR1__Field_Default_Value__c != null)
                        w.writeCData(jbfeedmap.TR1__Field_Default_Value__c);
                    else
                        w.writeCData('');
                }
                w.writeEndElement();

            }
            w.writeEndElement();
        }
        w.writeEndElement();
        jobsfeed = w.getXmlString();
    }

    

}