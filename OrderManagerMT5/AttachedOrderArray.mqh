//

class CAttachedOrderArray : public CArrayObjWithServices
{
public:
   CAttachedOrder    *AttachedOrder(int nIndex){return((CAttachedOrder*)At(nIndex));}  
   COrderFactoryBase* factory() { return ((CApplication*)app).orderfactory; }
   virtual bool  CreateElement(const int index) {
      m_data[index] = (CObject*)(factory().NewAttachedOrderObject());      
      return(true);
   } 
};
