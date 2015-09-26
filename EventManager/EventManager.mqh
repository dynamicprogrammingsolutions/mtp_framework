//
#include "..\Loader.mqh"

class CEventManager : public CEventManagerInterface
{
public:
   TraitGetType { return classEventManager; }
   
public:
   CArrayObj eventcontainer;
  
   virtual void Register(int& geteventid, CEventCallBackInterface* callback)
   {
      eventcontainer.Add(callback);
      geteventid = eventcontainer.Total();
   }
   
   virtual void Send(int eventid, CObject* eventobject = NULL)
   {
      if (eventid <= 0) return;
      CEventCallBackInterface* callback = eventcontainer.At(eventid-1);
      callback.Function(eventid,eventobject);
   } 

   virtual CObject* SendRetObj(int eventid, CObject* eventobject = NULL)
   {
      if (eventid <= 0) return eventobject;
      CEventCallBackInterface* callback = eventcontainer.At(eventid-1);
      return callback.FunctionRetObj(eventid,eventobject);
   } 

   virtual bool SendRetBool(int eventid, CObject* eventobject = NULL, bool defaultreturn = true)
   {
      if (eventid <= 0) return defaultreturn;
      CEventCallBackInterface* callback = eventcontainer.At(eventid-1);
      return callback.FunctionRetBool(eventid,eventobject);
   } 
   
};