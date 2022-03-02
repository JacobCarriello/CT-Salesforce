/***Author		:	Vickal Gupta
 * Last Updated	:	17 Nov 2016
 * Description	:	Provide Job feed through force.com site.
 **/

public with sharing class ExternalJobFeedsController {
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
    public ExternalJobFeedsController() {
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
        querystr += ', Name,TR1__Status__c from TR1__job__c where TR1__Post_Externally__c=true and TR1__Status__c != \'Closed\'';
		system.debug('Query: '+querystr);
        List < Sobject > jobsList;
            jobsList = database.query(querystr);

        w = new XmlStreamWriter();

        w.writeStartDocument('utf-8', '1.0');
        w.writeStartElement('', 'source', '');

        w.writeStartElement(null, 'publisher', null);
        w.writeCharacters(System.Label.TR1.JobsFeeds_Publisher);
        w.writeEndElement();

        w.writeStartElement(null, 'publisherurl', null);
        w.writeCharacters(System.Label.TR1.JobsFeeds_PublisherURL);
        w.writeEndElement();
        w.writeStartElement(null, 'lastBuildDate', null);
        w.writeCharacters(System.Now().format());
        w.writeEndElement();
		System.debug('>>>>>'+ jobsList);
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
                                fieldval = System.Label.TR1.JobsFeeds_JobBaseURL + fieldval;
                        }

                        if(jbfeedmap.TR1__element_Name__c == 'recordtype'){
                            system.debug('ReordTYpe '+ s.get(jbfeedmap.TR1__field_name__c));
                            fieldval = Schema.SObjectType.TR1__job__c.getRecordTypeInfosById().get(String.valueOf(s.get(jbfeedmap.TR1__field_name__c))).getname();
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
        //System.debug('XML String>> '+w.getXmlString());
        jobsfeed = w.getXmlString();
    }
}