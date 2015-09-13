//
#include "..\ServiceProviderBase\SymbolLoaderBase.mqh"
#include "..\SymbolInfoMT4\MTPSymbolInfo.mqh"
#include "SymbolLoader.mqh"

class CSymbolLoaderMT4 : public CSymbolLoader
{
public:
   virtual CSymbolInfoBase* NewSymbolInfoObject() {
      return new CMTPSymbolInfo();
   }
   virtual CSymbolInfoBase* LoadSymbol(const string in_symbol)
   {
      CMTPSymbolInfo* l_symbolinfo = CSymbolLoader::LoadSymbol(in_symbol);
      if (l_symbolinfo.LotValue() == 0) l_symbolinfo.Name(l_symbolinfo.Name());
      return l_symbolinfo;
   }
};


/*CMTPSymbolInfo *_symbol;

bool loadsymbol(const string in_symbol, const string function = "")
{
   return loadsymbol(in_symbol, _symbol, function);
}

bool loadsymbol(const string in_symbol, CMTPSymbolInfo*& _symbolinfo, const string function = "")
{
   if (_symbolinfo == NULL) _symbolinfo = new CMTPSymbolInfo();
   if (app().symbolloader.LoadSymbol(in_symbol,_symbolinfo)) {
      _symbolinfo.RefreshRates();
      return(true);
   } else {
      Print(__FUNCTION__,": Invalid Symbol: \""+in_symbol+"\"");
      return(false);
   }
}*/