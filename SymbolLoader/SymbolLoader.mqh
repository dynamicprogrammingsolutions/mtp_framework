//
#include "..\Loader.mqh"

#ifdef __MQL4__
  #include "..\SymbolInfoMT4\MTPSymbolInfo.mqh"
#else
#include "..\SymbolInfoMT5\MTPSymbolInfo.mqh"
#endif

class CSymbolLoader : public CSymbolLoaderBase
{
public:
   virtual int Type() const { return classSymbolLoader; }
public:
   CEventHandlerBase* event;
   virtual void Initalize()
   {
      event = app.GetService(srvEvent);
   }

   virtual CSymbolInfoBase* LoadByIndex(int nIndex){
      CObject *at;
      at = CSymbolLoader::At(nIndex);
      if (CheckPointer(at) == POINTER_INVALID) return(NULL);
      else return((CSymbolInfoBase*)at);
   }
   virtual CSymbolInfoBase* NewSymbolInfoObject() {
      return new CMTPSymbolInfo();
   }
   virtual CSymbolInfoBase* LoadSymbol(const string in_symbol)
   {
      CSymbolInfoBase* l_symbolinfo;
      for (int i = CSymbolLoader::Total()-1; i >= 0; i--) {
         l_symbolinfo = LoadByIndex(i);
         if (CheckPointer(l_symbolinfo) != POINTER_INVALID) {
            if (l_symbolinfo.Name() == in_symbol) {
            
#ifdef __MQL4__
               if (l_symbolinfo.LotValue() == 0) l_symbolinfo.Name(l_symbolinfo.Name());
#endif

               return(l_symbolinfo);
            }
         }
      }
      l_symbolinfo = Prepare(NewSymbolInfoObject());
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
      if (CheckPointer(_symbolinfo) == POINTER_INVALID) return(false);
      else return(true);
   }

};