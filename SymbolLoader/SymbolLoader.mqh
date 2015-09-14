//
#include "..\Loader.mqh"

class CSymbolLoader : public CSymbolLoaderBase
{
public:
   CEventHandlerBase* event;
   virtual void InitalizeService()
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
      Print("Calling Abstract Method: ",__FUNCTION__);
      return NULL;
   }
   virtual CSymbolInfoBase* LoadSymbol(const string in_symbol)
   {
      CSymbolInfoBase* l_symbolinfo;
      for (int i = CSymbolLoader::Total()-1; i >= 0; i--) {
         l_symbolinfo = LoadByIndex(i);
         if (CheckPointer(l_symbolinfo) != POINTER_INVALID) {
            if (l_symbolinfo.Name() == in_symbol) {
               return(l_symbolinfo);
            }
         }
      }
      l_symbolinfo = NewSymbolInfoObject();
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