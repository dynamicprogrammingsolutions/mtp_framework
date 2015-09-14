//

class CSymbolLoaderBase : public CServiceProviderArrayObj
{
protected:

public:
   /*CSymbolLoaderBase()
   {
      name = "symbolloader";
      srv = srvSymbolLoader;
   }*/
   virtual CSymbolInfoBase* LoadByIndex(int nIndex){
      AbstractFunctionWarning(__FUNCTION__);   
      return NULL;
   }
   
   virtual CSymbolInfoBase* LoadSymbol(const string in_symbol)
   {
      AbstractFunctionWarning(__FUNCTION__);   
      return NULL;
   }
   virtual bool LoadSymbol(const string in_symbol, CSymbolInfoBase*& _symbolinfo)
   {
      AbstractFunctionWarning(__FUNCTION__);   
      return false;
   }

};