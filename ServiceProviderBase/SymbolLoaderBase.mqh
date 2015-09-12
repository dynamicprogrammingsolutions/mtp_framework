//
#include "ServiceProviderArrayObj.mqh"
#include "..\ServiceProviderBase\SymbolInfoBase.mqh"

class CSymbolLoaderBase : public CServiceProviderArrayObj
{
public:
   CSymbolLoaderBase()
   {
      name = "symbolloader";
   }
   virtual CSymbolInfoBase* LoadByIndex(int nIndex){
      return NULL;
   }
   
   virtual CSymbolInfoBase* LoadSymbol(const string in_symbol)
   {
      return NULL;
   }
   bool LoadSymbol(const string in_symbol, CSymbolInfoBase*& _symbolinfo)
   {
      return false;
   }

};