//

class CSymbolLoaderInterface : public CServiceProviderArrayObj
{
protected:

public:
   /*CSymbolLoaderBase()
   {
      name = "symbolloader";
      srv = srvSymbolLoader;
   }*/
   virtual CSymbolInfoInterface* LoadByIndex(int nIndex){
      AbstractFunctionWarning(__FUNCTION__);   
      return NULL;
   }
   
   virtual CSymbolInfoInterface* LoadSymbol(const string in_symbol)
   {
      AbstractFunctionWarning(__FUNCTION__);   
      return NULL;
   }
   virtual bool LoadSymbol(const string in_symbol, CSymbolInfoInterface*& _symbolinfo)
   {
      AbstractFunctionWarning(__FUNCTION__);   
      return false;
   }

};