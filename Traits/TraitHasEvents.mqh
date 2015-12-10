#define TraitHasEvents int EventId(int& _id) { return App().eventmanager.SetId(_id); } void EventRegister(int& _id, CAppObject* callback) { App().eventmanager.Register(_id,callback); } void EventRegisterOnly(int _id, CAppObject* callback) { App().eventmanager.RegisterOnly(_id,callback); } bool EventSend(const int _id, CObject* object = NULL, const bool deleteobject = false) { return App().eventmanager.Send(_id,object,deleteobject); } virtual void EventListener(CAppObject* object) { int events[]; GetEvents(events); for (int i = 0; i < ArraySize(events); i++) { EventRegisterOnly(events[i],object); } }

/*
Requires:

void GetEvents(int& events[])
{
  ArrayResize(events,3);
  events[0] = EventId(EventName1);
  events[1] = EventId(EventName2);
  events[2] = EventId(EventName3);
}

*/

/*
//Original Code
//Converted by: http://www.textfixer.com/tools/remove-line-breaks.php

int EventId(int& _id)
{
  return App().eventmanager.SetId(_id);
}

void EventRegister(int& _id, CAppObject* callback)
{
  App().eventmanager.Register(_id,callback);
}

void EventRegisterOnly(int _id, CAppObject* callback)
{
  App().eventmanager.RegisterOnly(_id,callback);
}

bool EventSend(const int _id, CObject* object = NULL, const bool deleteobject = false)
{
   return App().eventmanager.Send(_id,object,deleteobject);
}

virtual void EventListener(CAppObject* object)
{
  int events[];
  GetEvents(events);
  for (int i = 0; i < ArraySize(events); i++) {
      EventRegisterOnly(events[i],object);
  }
}
*/
  