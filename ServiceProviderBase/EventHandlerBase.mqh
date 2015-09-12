//
#include "ServiceProvider.mqh"

class CEventHandlerBase : private CServiceProvider
{
public:
   CEventHandlerBase()
   {
      name = "event";
   }
   
   virtual void SetLogLevel(ushort _loglevel)
   {
   
   }
   
   virtual ushort GetLogLevel()
   {
      return(0);
   }
   
   
   virtual void Debug(const string message, const string function = "")
   {
   
   }

   virtual void Verbose(const string message, const string function = "")
   {

   }
   
   virtual void Info(const string message, const string function = "")
   {
      
   }

   virtual void Notice(const string message, const string function = "")
   {
      
   }
   
   virtual void Warning(const string message, const string function = "")
   {
      
   }

   virtual void Error(const string message, const string function = "")
   {
      
   }
   
   virtual bool Debug()
   {
      return false;
   }
   
   virtual bool Verbose()
   {
      return false;
   }
   
   virtual bool Info()
   {
      return false;
   }

   virtual bool Notice()
   {
      return false;
   }
   
   virtual bool Warning()
   {
      return false;
   }

   virtual bool Error()
   {
      return false;
   }   

};