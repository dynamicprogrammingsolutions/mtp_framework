//

class CSymbolLoaderBase : public CServiceProviderArrayObj
{
protected:
   CEventHandlerBase* event;

public:
   CSymbolLoaderBase()
   {
      name = "symbolloader";
      srv = srvSymbolLoader;
      event = app.GetService(srvEvent);
   }
   virtual CSymbolInfoBase* LoadByIndex(int nIndex){
      return NULL;
   }
   
   virtual CSymbolInfoBase* LoadSymbol(const string in_symbol)
   {
      return NULL;
   }
   virtual bool LoadSymbol(const string in_symbol, CSymbolInfoBase*& _symbolinfo)
   {
      return false;
   }

};