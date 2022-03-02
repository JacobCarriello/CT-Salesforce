/*
    Author : Veda arvind kaja.
    Date : 6/2/2017
    Description : 
*/
trigger UpdateConDate on Event (after insert) {

    UpdateContactFromEvent UpdateContactClass = new UpdateContactFromEvent();
    UpdateContactClass.UpdateContact( trigger.new);
}