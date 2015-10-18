//

class CAttachedOrderArray : public CAppObjectArrayObj
{
public:
   TraitAppAccess
   virtual int Type() const { return classMT5AttachedOrderArray; }
public:
   CAttachedOrderArray()
   {
      m_free_mode = true;
   }
   CAttachedOrder    *AttachedOrder(int nIndex){return((CAttachedOrder*)At(nIndex));}  
   virtual bool  CreateElement(const int index) {
      m_data[index] = (CObject*)(App().GetDependency(classOrder,classAttachedOrder));      
      return(true);
   } 
};
