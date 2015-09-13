//
#include "Loader.mqh"

class CAppObjectWithBaseServices : public CAppObject
{
public:
   CEventHandlerBase* event;
   CSymbolLoaderBase* symbolloader;   
   CSymbolInfoBase* _symbol;
   
   CAppObjectWithBaseServices()
   {
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
   
};