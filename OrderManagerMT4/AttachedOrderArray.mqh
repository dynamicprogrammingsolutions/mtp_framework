// *** CAttachedOrderArray ***
//#include "AttachedOrder.mqh"

class CAttachedOrderArray : public CArrayObj
{
   public: CAttachedOrder *AttachedOrder(int nIndex){return((CAttachedOrder*)CArrayObj::At(nIndex));}   
   virtual bool  CreateElement(const int index) {
      m_data[index] = (CObject*)(new CAttachedOrder());      
      return(true);
   }
};