//
class COrderManagerBase : public CServiceProvider
{
   protected:
      CEventHandlerBase* event;
      CSymbolLoaderBase* symbolloader;
      CSymbolInfoBase* _symbol;

   public:
      COrderManagerBase()
      {
         name = "ordermanager";
         srv = srvOrderManager;
         event = app.GetService(srvEvent);
         symbolloader = app.GetService(srvSymbolLoader);
      }
      
      void loadsymbol(string symbol)
      {
         _symbol = symbolloader.LoadSymbol(symbol);
      }
      
      void loadsymbol(string symbol, string function)
      {
         _symbol = symbolloader.LoadSymbol(symbol);
      }
   
      virtual COrderBaseBase* NewOrderObject() { return NULL ; }
      virtual COrderBaseBase* NewAttachedOrderObject() { return NULL; }
};