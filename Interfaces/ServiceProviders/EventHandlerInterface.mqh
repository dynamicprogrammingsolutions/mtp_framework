//
class CEventHandlerInterface : private CServiceProvider
{
public:
   /*CEventHandlerBase()
   {
      name = "event";
      srv = srvEvent;
   }*/
   
   virtual void SetLogLevel(ushort _loglevel)
   {
      AbstractFunctionWarning(__FUNCTION__);   
   }
   
   virtual ushort GetLogLevel()
   {
      AbstractFunctionWarning(__FUNCTION__);   
      return(0);
   }
   
   
   virtual void Debug(const string message, const string function = "")
   {
      AbstractFunctionWarning(__FUNCTION__);   
   
   }

   virtual void Verbose(const string message, const string function = "")
   {
      AbstractFunctionWarning(__FUNCTION__);   

   }
   
   virtual void Info(const string message, const string function = "")
   {
      AbstractFunctionWarning(__FUNCTION__);   
      
   }

   virtual void Notice(const string message, const string function = "")
   {
      AbstractFunctionWarning(__FUNCTION__);   
      
   }
   
   virtual void Warning(const string message, const string function = "")
   {
      AbstractFunctionWarning(__FUNCTION__);   
      
   }

   virtual void Error(const string message, const string function = "")
   {
      AbstractFunctionWarning(__FUNCTION__);   
      
   }
   
   virtual bool Debug()
   {
      AbstractFunctionWarning(__FUNCTION__);   
      return false;
   }
   
   virtual bool Verbose()
   {
      AbstractFunctionWarning(__FUNCTION__);   
      return false;
   }
   
   virtual bool Info()
   {
      AbstractFunctionWarning(__FUNCTION__);   
      return false;
   }

   virtual bool Notice()
   {
      AbstractFunctionWarning(__FUNCTION__);   
      return false;
   }
   
   virtual bool Warning()
   {
      AbstractFunctionWarning(__FUNCTION__);   
      return false;
   }

   virtual bool Error()
   {
      AbstractFunctionWarning(__FUNCTION__);   
      return false;
   }   

};