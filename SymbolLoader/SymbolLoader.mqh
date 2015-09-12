//
#include "..\ServiceProviderBase\SymbolLoaderBase.mqh"
#include "..\SymbolInfo\MTPSymbolInfo.mqh"

class CSymbolLoader : public CSymbolLoaderBase
{
private:
   CArrayObj container;

public:
   virtual CSymbolInfoBase* LoadByIndex(int nIndex){
      CObject *at;
      at = CSymbolLoader::At(nIndex);
      if (!isset(at)) return(NULL);
      else return((CMTPSymbolInfo*)at);
   }
   virtual CSymbolInfoBase* LoadSymbol(const string in_symbol)
   {
      CMTPSymbolInfo *l_symbolinfo;
      for (int i = CSymbolLoader::Total()-1; i >= 0; i--) {
         l_symbolinfo = LoadByIndex(i);
         if (isset(l_symbolinfo)) {
            if (l_symbolinfo.Name() == in_symbol) {
               if (l_symbolinfo.LotValue() == 0) l_symbolinfo.Name(l_symbolinfo.Name());
               return(l_symbolinfo);
            }
         }
      }
      l_symbolinfo = new CMTPSymbolInfo();
      if (l_symbolinfo.Name(in_symbol)) {
         CSymbolLoader::Add(l_symbolinfo);
         return(l_symbolinfo);
      } else {
         return(NULL);
      }
   }
   virtual bool LoadSymbol(const string in_symbol, CSymbolInfoBase*& _symbolinfo)
   {
      _symbolinfo = LoadSymbol(in_symbol);
      if (!isset(_symbolinfo)) return(false);
      else return(true);
   }

};

CMTPSymbolInfo *_symbol;

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
}